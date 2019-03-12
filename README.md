# Terraform Automation Demo using Google Cloud Provider

The purpose of this repository is to show case terraform automation for Google
Cloud. This demo will provision the following cloud resources associated to
corresponding terraform configurations:

| GCP Resource | Terraform Resource | Link to TerraHub Config |
|-----------------------|--------------------|-------------------------|
| Cloud Function | google_cloudfunctions_function | [google_function/.terrahub.yml#L24](https://github.com/TerraHubCorp/demo-terraform-automation-gcp/blob/master/google_function/.terrahub.yml#L24) |
| Cloud Storage | google_storage_bucket | [google_storage/.terrahub.yml#L7](https://github.com/TerraHubCorp/demo-terraform-automation-gcp/blob/master/google_storage/.terrahub.yml#L7) |
| Static Website | google_storage_bucket_object | [static_website/.terrahub.yml#L8](https://github.com/TerraHubCorp/demo-terraform-automation-gcp/blob/master/static_website/.terrahub.yml#L8) |
| IAM Policy | google_storage_bucket_iam_member | [iam_object_viewer/.terrahub.yml#L9](https://github.com/TerraHubCorp/demo-terraform-automation-gcp/blob/master/iam_object_viewer/.terrahub.yml#L9) |

Follow below instructions to try this out in your own Google Cloud account.

## Login to Google Cloud

Run the following command in terminal:
```shell
gcloud auth login
```

> NOTE: If you don't have Google Cloud CLI, check out this
[installation guide](https://cloud.google.com/sdk/install)

## Setup Environment Variables (Will Be Used Later)

Manual Setup (set values in double quotes and run the following commands in terminal):
```shell
export GOOGLE_CLOUD_PROJECT=""            ## e.g. terrahub-123456
export GOOGLE_APPLICATION_CREDENTIALS=""  ## e.g. ${HOME}/.config/gcloud/terraform.json
export BILLING_ID=""      ## e.g. 123456-ABCDEF-ZYXWVU
export PROJECT_NAME=""    ## e.g. TerraHub
export IAM_NAME=""        ## e.g. terraform
export IAM_DESC=""        ## e.g. terraform service account
export STORAGE_BUCKET=""  ## e.g. terrahub_bucket_123456
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
```

Your output should be similar to the one below:
```
Create in progress for [https://cloudresourcemanager.googleapis.com/v1/projects/***].
Waiting for [operations/***] to finish ... done.
```

Next, run the following command in terminal:
```shell
gcloud beta billing projects link ${GOOGLE_CLOUD_PROJECT} \
  --billing-account="${BILLING_ID}"
```

Your output should be similar to the one below:
```
billingAccountName: billingAccounts/***
billingEnabled: true
name: projects/***
projectId: ***
```

Finally, run the following commands in terminal:
```shell
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable storage-component.googleapis.com
```

Your output should be similar to the one below:
```
Operation "operations/***" finished successfully.
```

## Create Google Cloud IAM Service Account & Key

Run the following command in terminal:
```shell
gcloud iam service-accounts create ${IAM_NAME} \
  --display-name="${IAM_DESC}"
```

Your output should be similar to the one below:
```
Created service account [***].
```

After that, run the following command in terminal:
```shell
gcloud iam service-accounts keys create ${GOOGLE_APPLICATION_CREDENTIALS} \
  --iam-account="${IAM_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
```

Your output should be similar to the one below:
```
Created key [***] of type [json] as [***] for [***@***.iam.gserviceaccount.com]
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
Updated IAM policy for project [***].
bindings:
...
version: 1
```

## Terraform Automation and Orchestration Tool

The next couple of paragraphs are show casing the process of creating terraform
configurations using [TerraHub CLI](https://github.com/TerraHubCorp/terrahub).
We have opted to use YML format instead of HCL because it's easier and faster
to customize and automate terraform runs (see `terrahub component` command).

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

## Build Terraform Configurations from Scratch

Run the following commands in terminal:
```shell
mkdir demo-terraform-automation-gcp
cd demo-terraform-automation-gcp
terrahub project -n demo-terraform-automation-gcp
```

Your output should be similar to the one below:
```
✅ Project successfully initialized
```

> NOTE: If you want to jump directly to terraform automation part of the demo,
instead of creating `demo-terraform-automation-gcp` from scratch, clone current
repository, follow the instructions for `Update TerraHub's Project Config`,
continue to `Copy Source Code for Google Function and Static Website` and then
jump down to `Visualize TerraHub Components`. This way you will fast forward
through terrahub components creation and customization, and switch directly to
automation part.

## Update TerraHub's Project Config

Run the following commands in terminal:
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

## Copy Source Code for Google Function and Static Website

The source code of Google Function is stored in `index.js`:

```shell
echo 'exports.helloGET = (req, res) => { res.send("Hello World!\n"); };' > index.js
```

The source code of Static Website is cloned from another public repository:

```shell
git clone https://github.com/TerraHubCorp/www.git \
&& rm -rf ./www/.terrahub*
```

> NOTE: We are removing `.terrahub` folder (as shown above) because
already included terraform configuration is not relevant for this demo

## Create TerraHub Components from Templates

Run the following command in terminal:
```shell
terrahub component -t google_storage_bucket -n google_storage \
&& terrahub component -t google_cloudfunctions_function -n google_function -o ../google_storage \
&& terrahub component -t google_storage_bucket -n static_website \
&& terrahub component -t google_storage_bucket_iam_member -n iam_object_viewer -o ../static_website
```

Your output should be similar to the one below:
```
✅ Done
```

## Customize TerraHub Component for Storage Bucket

Run the following commands in terminal:
```shell
terrahub configure -i google_storage -c component.template.terraform.backend.local.path='/tmp/.terrahub/local_backend/google_storage/terraform.tfstate'
terrahub configure -i google_storage -c component.template.resource.google_storage_bucket.google_storage.name="${STORAGE_BUCKET}"
terrahub configure -i google_storage -c component.template.resource.google_storage_bucket.google_storage.location='US'
terrahub configure -i google_storage -c component.template.resource.google_storage_bucket.google_storage.force_destroy='true'
terrahub configure -i google_storage -c component.template.resource.google_storage_bucket.google_storage.project='${local.google_project_id}'
terrahub configure -i google_storage -c component.template.variable -D -y
```

Your output should be similar to the one below:
```
✅ Done
```

## Customize TerraHub Component for Google Cloud Function

Run the following commands in terminal:
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
terrahub configure -i google_function -c build.env.variables.THUB_FUNCTION_TXT='demo.txt'
terrahub configure -i google_function -c build.env.variables.COMPONENT_NAME='google_function'
terrahub configure -i google_function -c build.env.variables.OBJECT_NAME='google_storage_object'
terrahub configure -i google_function -c build.env.variables.THUB_BUILD_PATH='..'
terrahub configure -i google_function -c build.env.variables.THUB_BUILD_OK='false'
terrahub configure -i google_function -c build.env.variables.THUB_BUCKET_PATH="gs://${STORAGE_BUCKET}"
terrahub configure -i google_function -c build.env.variables.THUB_BUCKET_KEY='deploy/google_function'
terrahub configure -i google_function -c build.phases.pre_build.commands[0]='echo "BUILD: Running pre_build step"'
terrahub configure -i google_function -c build.phases.pre_build.commands[1]='./scripts/download.sh $THUB_FUNCTION_TXT $THUB_BUCKET_PATH/$THUB_BUCKET_KEY/$THUB_FUNCTION_TXT'
terrahub configure -i google_function -c build.phases.pre_build.commands[2]='./scripts/compare.sh $THUB_FUNCTION_TXT $THUB_BUILD_PATH/*.js'
terrahub configure -i google_function -c build.phases.pre_build.finally[0]='echo "BUILD: pre_build step successful"'
terrahub configure -i google_function -c build.phases.build.commands[0]='echo "BUILD: Running build step"'
terrahub configure -i google_function -c build.phases.build.commands[1]='./scripts/build.sh $COMPONENT_NAME $OBJECT_NAME $THUB_BUCKET_KEY/'
terrahub configure -i google_function -c build.phases.build.finally[0]='echo "BUILD: build step successful"'
terrahub configure -i google_function -c build.phases.post_build.commands[0]='echo "BUILD: Running post_build step"'
terrahub configure -i google_function -c build.phases.post_build.commands[1]='./scripts/shasum.sh $THUB_FUNCTION_TXT'
terrahub configure -i google_function -c build.phases.post_build.commands[2]='./scripts/zip.sh $THUB_FUNCTION_ZIP $THUB_BUILD_PATH/*.js'
terrahub configure -i google_function -c build.phases.post_build.commands[3]='./scripts/upload.sh $THUB_FUNCTION_TXT $THUB_BUCKET_PATH/$THUB_BUCKET_KEY/$THUB_FUNCTION_TXT'
terrahub configure -i google_function -c build.phases.post_build.commands[4]='rm -f .terrahub_build.env $THUB_FUNCTION_TXT'
terrahub configure -i google_function -c build.phases.post_build.finally[0]='echo "BUILD: post_build step successful"'
```

Your output should be similar to the one below:
```
✅ Done
```

## Customize TerraHub Component for Google Cloud Static WebSite

Run the following commands in terminal:
```shell
terrahub configure -i static_website -c component.template.terraform.backend.local.path='/tmp/.terrahub/local_backend/static_website/terraform.tfstate'
terrahub configure -i static_website -c component.template.resource.google_storage_bucket.static_website.name="${STORAGE_BUCKET}_website"
terrahub configure -i static_website -c component.template.resource.google_storage_bucket.static_website.location='US'
terrahub configure -i static_website -c component.template.resource.google_storage_bucket.static_website.force_destroy='true'
terrahub configure -i static_website -c component.template.resource.google_storage_bucket.static_website.project='${local.google_project_id}'
terrahub configure -i static_website -c component.template.resource.google_storage_bucket.static_website.website.main_page_suffix='index.html'
terrahub configure -i static_website -c component.template.resource.google_storage_bucket.static_website.website.not_found_page='/404.html'
terrahub configure -i static_website -c component.template.variable -D -y
terrahub configure -i static_website -c build.env.variables.THUB_ENV='dev'
terrahub configure -i static_website -c build.env.variables.THUB_INDEX_FILE='www.txt'
terrahub configure -i static_website -c build.env.variables.THUB_GS_PATH="gs://${STORAGE_BUCKET}_website"
terrahub configure -i static_website -c build.env.variables.THUB_ROBOTS='../www/robots.dev.txt'
terrahub configure -i static_website -c build.env.variables.THUB_BUILD_PATH='../www/build'
terrahub configure -i static_website -c build.env.variables.THUB_SOURCE_PATH='../www/assets ../www/static/fonts ../www/static/img ../www/views'
terrahub configure -i static_website -c build.env.variables.THUB_BUILD_OK='false'
terrahub configure -i static_website -c build.env.variables.THUB_MAX_AGE='600'
terrahub configure -i static_website -c build.phases.pre_build.commands[0]='echo "BUILD: Running pre_build step"'
terrahub configure -i static_website -c build.phases.pre_build.commands[1]='./scripts/download.sh $THUB_INDEX_FILE $THUB_GS_PATH/$THUB_INDEX_FILE'
terrahub configure -i static_website -c build.phases.pre_build.commands[2]='./scripts/compare.sh $THUB_INDEX_FILE $THUB_SOURCE_PATH'
terrahub configure -i static_website -c build.phases.pre_build.finally[0]='echo "BUILD: pre_build step successful"'
terrahub configure -i static_website -c build.phases.build.commands[0]='echo "BUILD: Running build step"'
terrahub configure -i static_website -c build.phases.build.commands[1]='../www/bin/compile.sh'
terrahub configure -i static_website -c build.phases.build.finally[0]='echo "BUILD: build step successful"'
terrahub configure -i static_website -c build.phases.post_build.commands[0]='echo "BUILD: Running post_build step"'
terrahub configure -i static_website -c build.phases.post_build.commands[1]='./scripts/shasum.sh $THUB_BUILD_PATH/$THUB_INDEX_FILE'
terrahub configure -i static_website -c build.phases.post_build.commands[2]='./scripts/upload.sh $THUB_BUILD_PATH $THUB_GS_PATH --cache-control max-age=$THUB_MAX_AGE'
terrahub configure -i static_website -c build.phases.post_build.commands[3]='rm -f .terrahub_build.env $THUB_INDEX_FILE'
terrahub configure -i static_website -c build.phases.post_build.finally[0]='echo "BUILD: post_build step successful"'
```

Your output should be similar to the one below:
```
✅ Done
```

## Customize TerraHub Component for IAM Member Object Viewer

Run the following commands in terminal:
```shell
terrahub configure -i iam_object_viewer -c component.template.terraform.backend.local.path='/tmp/.terrahub/local_backend/iam_object_viewer/terraform.tfstate'
terrahub configure -i iam_object_viewer -c component.template.data.terraform_remote_state.storage.backend='local'
terrahub configure -i iam_object_viewer -c component.template.data.terraform_remote_state.storage.config.path='/tmp/.terrahub/local_backend/static_website/terraform.tfstate'
terrahub configure -i iam_object_viewer -c component.template.resource.google_storage_bucket_iam_member.iam_object_viewer.bucket="${STORAGE_BUCKET}_website"
terrahub configure -i iam_object_viewer -c component.template.resource.google_storage_bucket_iam_member.iam_object_viewer.role="roles/storage.objectViewer"
terrahub configure -i iam_object_viewer -c component.template.resource.google_storage_bucket_iam_member.iam_object_viewer.member="allUsers"
terrahub configure -i iam_object_viewer -c component.template.variable -D -y
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
Project: demo-terraform-automation-gcp
 ├─ google_storage [path: ./google_storage]
 │  └─ google_function [path: ./google_function]
 └─ static_website [path: ./static_website]
    └─ iam_object_viewer [path: ./iam_object_viewer]
```

## Run TerraHub Automation

### Prepare Storage Resources

Run the following command in terminal:
```shell
terrahub run -y -a -i google_storage,static_website
```

Your output should be similar to the one below:
```
```

### Prepare Source Code for Deployment

Run the following command in terminal:

```shell
terrahub build -i google_function,static_website
```

Your output should be similar to the one below:
```
```

> NOTE: If you get an error saying `ServiceException: 401 Anonymous caller
does not have storage.objects.get access to [***]`, run `gsutil config` and
setup default project id.

### Run TerraHub Automation

Run the following command in terminal:
```shell
terrahub run -y -a
```

Your output should be similar to the one below:
```
```

## Testing Deployed Cloud Resources

Check if backend was deployed successfully. Run the following command in terminal:
```
curl https://us-central1-terrahub-123456.cloudfunctions.net/demofunctionxxxxxxxx
```

Check if frontend was deployed successfully. Run the following command in terminal:
```
curl https://${STORAGE_BUCKET}_website.storage.googleapis.com/index.html
```
