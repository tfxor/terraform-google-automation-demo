# Define list of variables to be output

output "email" {
  value = "${google_service_account.project-service-account.email}"
}

output "name" {
  value = "${google_service_account.project-service-account.name}"
}

output "unique_id" {
  value = "${google_service_account.project-service-account.unique_id}"
}