resource "google_compute_global_address" "sqlip" {
  name          = "sqlip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.demovpc.self_link
}

resource "google_service_networking_connection" "sqlconnection" {
  network                 = google_compute_network.demovpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sqlip.name]
}

resource "random_id" "dbpassword" {
  byte_length = 10
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "db" {
  name             = "db-${random_id.db_name_suffix.hex}"
  region           = var.region
  database_version = "POSTGRES_14"
  deletion_protection = false # for development only

  depends_on = [google_service_networking_connection.sqlconnection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false # public IP
      private_network = google_compute_network.demovpc.self_link
    }
  }
}

resource "google_sql_user" "demo" {
  name     = "demo"
  password = "${random_id.dbpassword.hex}"
  instance = google_sql_database_instance.db.name
}

resource "google_sql_database" "db" {
  name       = "sinatra-practice-production"
  instance   = google_sql_database_instance.db.name
  depends_on = [google_sql_user.demo]
}