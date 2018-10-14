resource "google_service_account" "service_account" {
  display_name = "${var.google_service_account_display_name}"
  account_id   = "${var.google_service_account_name}"
  project      = "${var.google_project_id}"
}
