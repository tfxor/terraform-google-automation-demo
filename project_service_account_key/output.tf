# Define list of variables to be output

output "name" {
  value = "${google_service_account_key.project_service_account_key.name}"
}

output "public_key" {
  value = "${google_service_account_key.project_service_account_key.public_key}"
}

output "private_key" {
  value = "${google_service_account_key.project_service_account_key.private_key}"
}

output "valid_after" {
  value = "${google_service_account_key.project_service_account_key.valid_after}"
}

output "valid_before" {
  value = "${google_service_account_key.project_service_account_key.valid_before}"
}