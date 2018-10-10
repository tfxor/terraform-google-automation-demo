# Define list of variables to be output

output "etag" {
  value = "${google_project_iam_binding.project_iam_policy_binding_compute_admin.etag}"
}