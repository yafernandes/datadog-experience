#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source ${1}.env

cd terraform

terraform apply --auto-approve \
  -state="$DDEXP_NAMESPACE.tfstate" \
  -var="region=$DDEXP_REGION" \
  -var="namespace=$DDEXP_NAMESPACE" \
  -var="creator=$DDEXP_CREATOR"

cd -

cd ansible

ansible-playbook -i $DDEXP_NAMESPACE-inventory.txt otel.yaml \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e ansible_ssh_private_key_file=../terraform/$DDEXP_NAMESPACE-private_key.pem \
  -e datadog_api_key=$DD_API_KEY

cd -
