# Define list of variables to be output

output "etag" {
  value = "${google_project_iam_binding.project_iam_binding_storage_admin.etag}"
}
