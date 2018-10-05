# Define list of variables to be output

output "etag" {
  value = "${google_project_iam_binding.project-iam-policy-binding-storage-admin.etag}"
}