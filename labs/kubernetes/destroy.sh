#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ ! -f $1.env ]; then
  echo -e "\033[0;31mEnv file does not exist\033[0m\007"
  ls  -1 *.env | xargs -n 1 basename
  exit 1
else
  source $1.env
  DDEXP_NAMESPACE=$1
fi

cd terraform

terraform workspace select $DDEXP_NAMESPACE

terraform destroy --auto-approve \
  -var="region=$DDEXP_REGION" \
  -var="namespace=$DDEXP_NAMESPACE" \
  -var="creator=$DDEXP_CREATOR" \
  -var="workers_count=$DDEXP_WORKERS_COUNT" \
  -var="architecture=$DDEXP_ARCHITECTURE"
cd -

resources=$(cat terraform/terraform.tfstate.d/$DDEXP_NAMESPACE/terraform.tfstate | jq '.resources | length')

if (( $resources == 0 )); then
    set +eo pipefail

    cd terraform
    terraform workspace select default
    terraform workspace delete $DDEXP_NAMESPACE
    cd -

    rm terraform/$DDEXP_NAMESPACE-private_key.pem
    rm ansible/$DDEXP_NAMESPACE-inventory.txt
    rm $DDEXP_NAMESPACE.zip
    rm ~/.kube/$DDEXP_NAMESPACE.config
fi

