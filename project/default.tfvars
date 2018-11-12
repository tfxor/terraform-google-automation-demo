# Specify default values for variables defined in variables.tf

#############
# top level #
#############
google_project_name                = "project"
google_project_id                  = "project"
google_org_id                      = ""
google_project_folder_id           = ""
google_billing_account             = ""
google_project_skip_delete         = false
google_project_auto_create_network = true
google_location_id                 = "us-central"

##########
# labels #
##########
default_labels = {
  "name"        = "project"
  "description" = "managed-by-terrahub"
  "thubcode"    = "f2754a99"
  "thubenv"     = "default"
}
custom_labels  = {}
