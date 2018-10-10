resource "google_project_iam_binding" "project_iam_policy_binding_compute_admin" {
  project = "${var.google_project_id}"
  role    = "${var.google_project_role}"
  members = "${var.google_project_members}"
}