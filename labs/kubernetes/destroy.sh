#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source $1.env

cd terraform
terraform destroy --auto-approve \
  -state="$DDEXP_NAMESPACE.tfstate" \
  -var="region=$DDEXP_REGION" \
  -var="namespace=$DDEXP_NAMESPACE" \
  -var="creator=$DDEXP_CREATOR" \
  -var="workers_count=$DDEXP_WORKERS_COUNT"
cd -
