#!/usr/bin/env bash

gcloud --version > /dev/null 2>&1 || { echo >&2 'gcloud is missing. aborting...'; exit 1; }
jq --version > /dev/null 2>&1 || { echo >&2 'jq is missing. aborting...'; exit 1; }
npm --version > /dev/null 2>&1 || { echo >&2 'npm is missing. aborting...'; exit 1; }
export NODE_PATH="$(npm root -g)"

if [ -z "${BRANCH_FROM}" ]; then BRANCH_FROM = "dev"; fi
if [ -z "${BRANCH_TO}" ]; then BRANCH_TO = "dev"; fi
if [ "${BRANCH_TO}" != "dev" ]; then THUB_ENV="-e ${BRANCH_TO}"; fi
if [ "${THUB_STATE}" == "approved" ]; then THUB_APPLY="-a"; fi

git --version > /dev/null 2>&1 || { echo >&2 'git is missing. aborting...'; exit 1; }
git checkout $BRANCH_TO
git checkout $BRANCH_FROM

GOOGLE_CLOUD_PROJECT="$(gcloud config list --format=json | jq '.core.project')"
GOOGLE_APPLICATION_CREDENTIALS="${HOME}/${GOOGLE_CLOUD_PROJECT}.json"
echo $GOOGLE_APPLICATION_CREDENTIALS_CONTENT > ${GOOGLE_APPLICATION_CREDENTIALS}
gcloud auth activate-service-account --key-file ${GOOGLE_APPLICATION_CREDENTIALS}
BILLING_ID="$(gcloud beta billing accounts list --format=json | jq '.[0].name[16:]')"
SERVICE_ACCOUNT="terraform@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"

terrahub --version > /dev/null 2>&1 || { echo >&2 'terrahub is missing. aborting...'; exit 1; }
terrahub configure -c template.locals.google_project_id="${GOOGLE_CLOUD_PROJECT}"
terrahub configure -c template.locals.google_billing_account="${BILLING_ID}"

terrahub run -y -b ${THUB_APPLY} ${THUB_ENV}
