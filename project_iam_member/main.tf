resource "google_project_iam_member" "project_iam_member" {
  project = "${var.google_project_id}"
  role    = "${var.google_project_role}"
  member  = "${var.google_project_member}"
}
