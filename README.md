# Terraform Automation using Google Provider

## Login to Google Cloud

Run the following command in terminal:
```shell
gcloud auth login
```

> NOTE: If you don't have Google Cloud CLI, check out this
[installation guide](https://cloud.google.com/sdk/install)

## Setup Environment Variables (Will Be Used Later)

Manual Setup (set values in double quotes and run the following command in terminal):
```shell
export GOOGLE_CLOUD_PROJECT=""            ## e.g. terrahub-123456
export GOOGLE_APPLICATION_CREDENTIALS=""  ## e.g. ${HOME}/.config/gcloud/terraform.json
export ORG_ID=""        ## e.g. 123456789012
export BILLING_ID=""    ## e.g. 123456-ABCDEF-ZYXWVU
export PROJECT_NAME=""  ## e.g. TerraHub
export IAM_NAME=""      ## e.g. terraform
export IAM_DESC=""      ## e.g. terraform service account
```

### Setup ORG_ID Programmatically

Automated Setup (run the following command in terminal):
```shell
export ORG_ID="$(gcloud organizations list --format=json | jq '.[0].name[14:]')"
```

> NOTE: If you don't have JQ CLI, check out this
[installation guide](https://stedolan.github.io/jq/download/)

### Setup BILLING_ID Programmatically

Automated Setup (run the following command in terminal):
```shell
export BILLING_ID="$(gcloud beta billing accounts list --format=json | jq '.[0].name[16:]')"
```

> NOTE: If you don't have JQ CLI, check out this
[installation guide](https://stedolan.github.io/jq/download/)

## Create Google Cloud Project & Billing

Run the following command in terminal:
```shell
gcloud projects create ${GOOGLE_CLOUD_PROJECT} \
  --name="${PROJECT_NAME}" \
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

Your output should be similar to the one below:
```
```

## Create Google Cloud IAM Service Account & Key

Run the following command in terminal:
```shell
gcloud iam service-accounts create ${IAM_NAME} \
  --display-name="${IAM_DESC}"

gcloud iam service-accounts keys create ${GOOGLE_APPLICATION_CREDENTIALS} \
  --iam-account="${IAM_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
```

Your output should be similar to the one below:
```
```

## Add IAM Policy Binding to Google Cloud Project

Run the following command in terminal:
```shell
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
  --member="serviceAccount:${IAM_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
  --role="roles/editor"
```

Your output should be similar to the one below:
```
```

## Add IAM Policy Binding to Google Cloud Organization

Run the following command in terminal:
```shell
gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member="serviceAccount:${IAM_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectCreator"

gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member="serviceAccount:${IAM_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
  --role="roles/billing.user"
```

Your output should be similar to the one below:
```
```

## Create Terraform Configurations Using TerraHub

Run the following commands in terminal:
```shell
terrahub --help | head -3
```

Your output should be similar to the one below:
```
Usage: terrahub [command] [options]

terrahub@0.1.28 (built: 2019-02-08T17:17:41.912Z)
```

> NOTE: If you don't have TerraHub CLI, check out this
[installation guide](https://www.npmjs.com/package/terrahub)

Run the following command in terminal:
```shell
mkdir demo-terraform-google
cd demo-terraform-google
terrahub project -n demo-terraform-google
```

Your output should be similar to the one below:
```
✅ Project successfully initialized
```

## Create TerraHub Components

Run the following command in terminal:
```shell
terrahub component -t google_project -n project
terrahub component -t google_service_account -n service_account -o ../project
terrahub component -t google_service_account_key -n service_account_key -o ../service_account
terrahub component -t google_project_iam_member -n project_iam_member -o ../project
terrahub component -t google_project_iam_binding -n project_iam_policy_binding_storage_admin -o ../project_iam_member
terrahub component -t google_project_iam_binding -n project_iam_policy_binding_compute_admin -o ../project_iam_member
```

Your output should be similar to the one below:
```
✅ Done
```

## Visualize TerraHub Components

Run the following command in terminal:
```shell
terrahub graph
```

Your output should be similar to the one below:
```
Project: demo-terraform-google
 └─ project [path: ./project]
    ├─ project_iam_member [path: ./project_iam_member]
    │  ├─ project_iam_binding_compute_admin [path: ./project_iam_binding_compute_admin]
    │  └─ project_iam_binding_storage_admin [path: ./project_iam_binding_storage_admin]
    └─ service_account [path: ./service_account]
       └─ service_account_key [path: ./service_account_key]
```

## Update Project Config

Run the following command in terminal:
```shell
terrahub configure -c template.locals.google_org_id="${ORG_ID}"
terrahub configure -c template.locals.google_billing_account="${BILLING_ID}"
terrahub configure -c template.locals.google_project_id="${GOOGLE_CLOUD_PROJECT}"
```

Your output should be similar to the one below:
```
✅ Done
```

## Run TerraHub Automation

Run the following command in terminal:
```shell
terrahub run -a -y
```

Your output should be similar to the one below:
```
```
