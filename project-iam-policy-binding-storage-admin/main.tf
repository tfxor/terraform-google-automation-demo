resource "google_project_iam_binding" "project-iam-policy-binding-storage-admin" {
  project = "${var.google_project_id}"
  role    = "${var.google_project_role}"

  members = "${var.google_project_members}"
}