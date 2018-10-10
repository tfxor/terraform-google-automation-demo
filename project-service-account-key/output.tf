# Define list of variables to be output

output "name" {
  value = "${google_service_account_key.project-service-account-key.name}"
}

output "public_key" {
  value = "${google_service_account_key.project-service-account-key.public_key}"
}

output "private_key" {
  value = "${google_service_account_key.project-service-account-key.private_key}"
}

output "valid_after" {
  value = "${google_service_account_key.project-service-account-key.valid_after}"
}

output "valid_before" {
  value = "${google_service_account_key.project-service-account-key.valid_before}"
}