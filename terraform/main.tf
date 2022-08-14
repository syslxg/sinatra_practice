provider "google" {
  project = var.project
  credentials = file("total-yen-359317-85c6f6593522.json")
}

provider "google-beta" {
  project = var.project
  credentials = file("total-yen-359317-85c6f6593522.json")
}

resource "google_compute_network" "demovpc" {
  name = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "demosubnet" {
  name                     = var.network_name
  ip_cidr_range            = "10.0.0.0/24"
  network                  = google_compute_network.demovpc.self_link
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "router"
  network                  = google_compute_network.demovpc.self_link
  region                   = var.region
}

resource "google_compute_router_nat" "simple-nat" {
  name                               = "nat-1"
  router                             = "${google_compute_router.router.name}"
  region                             = "us-central1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = google_compute_network.demovpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
  source_ranges = ["0.0.0.0/0"]
}

data "template_file" "group-startup-script" {
  template = file("install.sh")
}

module "mig_template" {
  source_image_project = "ubuntu-os-cloud"
  source_image = "ubuntu-2004-lts"
  machine_type = "e2-micro"
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  network    = google_compute_network.demovpc.self_link
  subnetwork = google_compute_subnetwork.demosubnet.self_link
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix    = var.network_name
  startup_script = data.template_file.group-startup-script.rendered
  tags = [
    var.network_name,
    "ssh"
  ]
}

module "mig" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  instance_template = module.mig_template.self_link
  region            = var.region
  hostname          = var.network_name
  target_size       = 1
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = google_compute_network.demovpc.self_link
  subnetwork = google_compute_subnetwork.demosubnet.self_link
  depends_on = [google_sql_database_instance.db]
}

# [START cloudloadbalancing_ext_http_gce_http_redirect]
module "gce-lb-http" {
  source               = "GoogleCloudPlatform/lb-http/google"
  name                 = "lb"
  project              = var.project
  target_tags          = [var.network_name]
  firewall_networks    = [google_compute_network.demovpc.name]
  ssl                  = false


  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable      = false
        sample_rate = null
      }

      groups = [
        {
          group                        = module.mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        }
      ]
      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}