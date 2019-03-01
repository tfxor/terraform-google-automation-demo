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
export BILLING_ID=""    ## e.g. 123456-ABCDEF-ZYXWVU
export PROJECT_NAME=""  ## e.g. TerraHub
export IAM_NAME=""      ## e.g. terraform
export IAM_DESC=""      ## e.g. terraform service account
```
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
  --set-as-default

gcloud beta billing projects link ${GOOGLE_CLOUD_PROJECT} \
  --billing-account="${BILLING_ID}"

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
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

## Create Terraform Configurations Using TerraHub

Run the following commands in terminal:
```shell
terrahub --help | head -3
```

Your output should be similar to the one below:
```
Usage: terrahub [command] [options]

terrahub@0.0.1 (built: 2018-04-07T19:15:39.787Z)
```

> NOTE: If you don't have TerraHub CLI, check out this
[installation guide](https://www.npmjs.com/package/terrahub)

Run the following command in terminal:
```shell
mkdir demo-terraform-automation-google
cd demo-terraform-automation-google
terrahub project -n demo-terraform-automation-google
```

Your output should be similar to the one below:
```
✅ Project successfully initialized
```

## Create TerraHub Components from Templates

Run the following command in terminal:
```shell
terrahub component -t google_storage_bucket -n google_storage \
&& terrahub component -t google_cloudfunctions_function -n google_function -o ../google_storage
```

Your output should be similar to the one below:
```
✅ Done
```

## Update Project Config

Run the following command in terminal:
```shell
terrahub configure -c terraform.version=0.11.11
terrahub configure -c template.provider.google={}
terrahub configure -c template.locals.google_project_id="${GOOGLE_CLOUD_PROJECT}"
terrahub configure -c template.locals.google_billing_account="${BILLING_ID}"
```

Your output should be similar to the one below:
```
✅ Done
```

## Customize TerraHub Component for Storage Bucket

Run the following command in terminal:
```shell
terrahub configure -i google_storage -c component.template.terraform.backend.local.path='/tmp/.terrahub/local_backend/google_storage/terraform.tfstate'
terrahub configure -i google_storage -c component.template.resource.google_storage_bucket.google_storage.name='demo_terraform_automation_${local.project["code"]}'
terrahub configure -i google_storage -c component.template.resource.google_storage_bucket.google_storage.location='US'
terrahub configure -i google_storage -c component.template.resource.google_storage_bucket.google_storage.project='${local.google_project_id}'
terrahub configure -i google_storage -c component.template.variable -D -y
```

Your output should be similar to the one below:
```
✅ Done
```

## Customize TerraHub Component for Google Cloud Function

Run the following command in terminal:
```shell
terrahub configure -i google_function -c component.template.terraform.backend.local.path='/tmp/.terrahub/local_backend/google_function/terraform.tfstate'
terrahub configure -i google_function -c component.template.data.terraform_remote_state.storage.backend='local'
terrahub configure -i google_function -c component.template.data.terraform_remote_state.storage.config.path='/tmp/.terrahub/local_backend/google_storage/terraform.tfstate'
terrahub configure -i google_function -c component.template.resource.google_storage_bucket_object.google_storage_object.name='demo.zip'
terrahub configure -i google_function -c component.template.resource.google_storage_bucket_object.google_storage_object.bucket='${data.terraform_remote_state.storage.thub_id}'
terrahub configure -i google_function -c component.template.resource.google_storage_bucket_object.google_storage_object.source='./demo.zip'
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.depends_on[0]='google_storage_bucket_object.google_storage_object'
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.name='demofunction${local.project["code"]}'
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.region='us-central1'
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.runtime='nodejs8'
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.description='My demo function'
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.available_memory_mb=128
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.source_archive_bucket='${data.terraform_remote_state.storage.thub_id}'
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.source_archive_object='${google_storage_bucket_object.google_storage_object.name}'
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.trigger_http=true
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.timeout=60
terrahub configure -i google_function -c component.template.resource.google_cloudfunctions_function.google_function.entry_point='helloGET'
terrahub configure -i google_function -c component.template.variable -D -y
terrahub configure -i google_function -c component.template.output -D -y
terrahub configure -i google_function -c component.template.output.id.value='${google_cloudfunctions_function.google_function.id}'
terrahub configure -i google_function -c component.template.output.trigger_url.value='${google_cloudfunctions_function.google_function.https_trigger_url}'
terrahub configure -i google_function -c build.env.variables.THUB_FUNCTION_ZIP='demo.zip'
terrahub configure -i google_function -c build.env.variables.THUB_BUILD_PATH='..'
terrahub configure -i google_function -c build.env.variables.THUB_FUNCTION_TXT='demo.txt'
terrahub configure -i google_function -c build.env.variables.THUB_BUILD_OK='true'
terrahub configure -i google_function -c build.phases.pre_build.commands[0]='echo "BUILD: Running pre_build step"'
terrahub configure -i google_function -c build.phases.pre_build.commands[1]='if [ ! -e "$THUB_FUNCTION_TXT" ]; then touch "$THUB_FUNCTION_TXT"; fi'
terrahub configure -i google_function -c build.phases.pre_build.finally[0]='echo "BUILD: pre_build step successful"'
terrahub configure -i google_function -c build.phases.build.commands[0]='echo "BUILD: Running build step"'
terrahub configure -i google_function -c build.phases.build.commands[1]='if [ "$(head -n 1 "$THUB_FUNCTION_TXT")" != "$(stat -c %y "${THUB_BUILD_PATH}/demo.js")" ]; then zip -j ${THUB_FUNCTION_ZIP} ${THUB_BUILD_PATH}/demo.js; fi'
terrahub configure -i google_function -c build.phases.build.commands[2]='if [ "$(head -n 1 "$THUB_FUNCTION_TXT")" != "$(stat -c %y "${THUB_BUILD_PATH}/demo.js")" ]; then terrahub configure -i google_function -c component.template.resource.google_storage_bucket_object.google_storage_object.name=$(date +%s).zip; fi'
terrahub configure -i google_function -c build.phases.build.finally[0]='echo "BUILD: build step successful"'
terrahub configure -i google_function -c build.phases.post_build.commands[0]='echo "BUILD: Running post_build step"'
terrahub configure -i google_function -c build.phases.post_build.commands[1]='echo $(stat -c %y "${THUB_BUILD_PATH}/demo.js") > "$THUB_FUNCTION_TXT"'
terrahub configure -i google_function -c build.phases.post_build.finally[0]='echo "BUILD: post_build step successful"'
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
Project: demo-terraform-automation-google
 └─ google_storage [path: ./google_storage]
    └─ google_function [path: ./google_function]
```


## Run TerraHub Automation

Run the following command in terminal:
```shell
terrahub build -i google_function
terrahub run -a -y
```

Your output should be similar to the one below:
```
```

## Run Test Command

Run the following command in terminal:
```
curl https://us-central1-terrahub-123456.cloudfunctions.net/demofunctionxxxxxxxx
```