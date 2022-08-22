# sinatra_practice

Code from https://medium.com/@rileythompson/setting-up-a-simple-sinatra-blog-app-db56dda4c280

This is a sinatra modular app, as opposed to classic applications that are using the Top Level DSL. See https://www.oreilly.com/library/view/sinatra-up-and/9781449306847/ch04.html


## Monitor

Datadog is used for system metrics collection, APM and dashboards.


## deploy on GCP with terraform

Variables:

- A DataDog api key is needed.
- By default 1 VM will be created.
- Set other GCP settings as needed.

Outputs:
- IP address of the HTTP load balancer