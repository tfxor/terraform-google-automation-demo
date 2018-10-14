# Define list of variables to be output

output "email" {
  value = "${google_service_account.service_account.email}"
}

output "name" {
  value = "${google_service_account.service_account.name}"
}

output "unique_id" {
  value = "${google_service_account.service_account.unique_id}"
}
