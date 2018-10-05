# Define list of variables to be output

output "number" {
  value = "${google_project.test-team-project.number}"
}