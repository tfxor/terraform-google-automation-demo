resource "google_project_service" "project-service-enable-compute" {
  project            = "${var.google_project_id}-f2754a99"
  service            = "${var.google_project_service_name}.googleapis.com"
  disable_on_destroy = "${var.google_project_disable_on_destroy}"
}