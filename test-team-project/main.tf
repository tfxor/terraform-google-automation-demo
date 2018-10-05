resource "google_project" "test-team-project" {
  name                = "${var.google_project_name}"
  project_id          = "${lower(var.google_project_id)}-f2754a99"
  org_id              = "${var.google_org_id}"
  folder_id           = "${var.google_project_folder_id}"
  billing_account     = "${var.google_billing_account}"
  skip_delete         = "${var.google_project_skip_delete}"
  auto_create_network = "${var.google_project_auto_create_network}"

  labels              = "${merge(var.default_labels, var.custom_labels)}"
}
