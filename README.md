# Terraform Demo using Google provider

## Setup Google Cloud ENV Variables
```shell
export ORG_ID=""        ## e.g. 123456789012
export BILLING_ID=""    ## e.g. 123456-ABCDEF-ZYXWVU
export PROJECT_ID=""    ## e.g. terrahub-123456
export PROJECT_NAME=""  ## e.g. TerraHub
export IAM_NAME=""      ## e.g. terraform
export IAM_DESC=""      ## e.g. terraform service account
export GOOGLE_APPLICATION_CREDENTIALS=""  ## e.g. ${HOME}/.config/gcloud/terraform.json
```

## Login to Google Cloud
```shell
gcloud auth login
```

## Create Google Cloud Project & Billing
```shell
gcloud projects create ${PROJECT_ID} \
  --name="${PROJECT_NAME}"
  --organization="${ORG_ID}" \
  --set-as-default

gcloud config set project ${PROJECT_ID}

gcloud beta billing projects link ${PROJECT_ID} \
  --billing-account="${BILLING_ID}"
```

## Create Google Cloud IAM Service Account & Key
```shell
gcloud iam service-accounts create ${IAM_NAME} \
  --display-name="${IAM_DESC}"

gcloud iam service-accounts keys create ${GOOGLE_APPLICATION_CREDENTIALS} \
  --iam-account="${IAM_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
```

## Add IAM Policy Binding to Google Cloud Project
```shell
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${IAM_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/editor"
```

## Add IAM Policy Binding to Google Cloud Organization
```shell
gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member="serviceAccount:${IAM_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectCreator"

gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member="serviceAccount:${IAM_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/billing.user"
```

## Enable Google Cloud Service
```shell
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
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
```

## Update TerraHub Component Config
NOTE: BELOW COMMANDS ARE WORK IN PROGRESS / NOT IMPLEMENTED YET
```shell
terrahub configure -c project terraform.var.google_org_id="${ORG_ID}"
terrahub configure -c project terraform.var.google_project_id="${PROJECT_ID}"
terrahub configure -c project terraform.var.google_billing_account="${BILLING_ID}"
```

## Execute TerraHub Component
```shell
terrahub run -a -y
```
