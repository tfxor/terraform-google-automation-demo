# Terraform Demo using Google provider

## Login to Google Cloud
```shell
gcloud auth login
```

## Get Google Cloud values for ORG_ID and BILLING_ID
```shell
gcloud organizations list
gcloud beta billing accounts list
```

## Setup Google Cloud ENV Variables
```shell
export GOOGLE_CLOUD_PROJECT=""            ## e.g. terrahub-123456
export GOOGLE_APPLICATION_CREDENTIALS=""  ## e.g. ${HOME}/.config/gcloud/terraform.json
export ORG_ID=""        ## e.g. 123456789012
export BILLING_ID=""    ## e.g. 123456-ABCDEF-ZYXWVU
export PROJECT_NAME=""  ## e.g. TerraHub
export IAM_NAME=""      ## e.g. terraform
export IAM_DESC=""      ## e.g. terraform service account
```

## Create Google Cloud Project & Billing
```shell
gcloud projects create ${GOOGLE_CLOUD_PROJECT} \
  --name="${PROJECT_NAME}"
  --organization="${ORG_ID}" \
  --set-as-default

gcloud config set project ${GOOGLE_CLOUD_PROJECT}

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com

gcloud beta billing projects link ${GOOGLE_CLOUD_PROJECT} \
  --billing-account="${BILLING_ID}"
```

## Create Google Cloud IAM Service Account & Key
```shell
gcloud iam service-accounts create ${IAM_NAME} \
  --display-name="${IAM_DESC}"

gcloud iam service-accounts keys create ${GOOGLE_APPLICATION_CREDENTIALS} \
  --iam-account="${IAM_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
```

## Add IAM Policy Binding to Google Cloud Project
```shell
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
  --member="serviceAccount:${IAM_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
  --role="roles/editor"
```

## Add IAM Policy Binding to Google Cloud Organization
```shell
gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member="serviceAccount:${IAM_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectCreator"

gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member="serviceAccount:${IAM_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
  --role="roles/billing.user"
```

## Create TerraHub Project
```shell
mkdir demo-terraform-google
cd demo-terraform-google
terrahub project -n demo-terraform-google
```

## Create TerraHub Component
```shell
terrahub component -t google_project -n project
terrahub component -t google_service_account -n project_service_account -o ../project
terrahub component -t google_service_account_key -n project_service_account_key -o ../project_service_account
terrahub component -t google_project_iam_member -n project_members -o ../project
terrahub component -t google_project_iam_binding -n project_iam_policy_binding_storage_admin -o ../project_members
terrahub component -t google_project_iam_binding -n project_iam_policy_binding_compute_admin -o ../project_members
```

## Update TerraHub Component Config
```shell
terrahub configure -c terraform.var.google_org_id="${ORG_ID}"
terrahub configure -c terraform.var.google_billing_account="${BILLING_ID}"
terrahub configure -c terraform.var.google_project_id="${GOOGLE_CLOUD_PROJECT}"
```

## Execute TerraHub Component
```shell
terrahub run -a -y
```
