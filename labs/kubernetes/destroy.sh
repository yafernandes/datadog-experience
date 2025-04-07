#!/bin/bash
set -euox pipefail
IFS=$'\n\t'

export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DATA_DIR="$SCRIPT_DIR/clusters/$1"

if [ -d $DATA_DIR ]
then
  cd $DATA_DIR
  if [ -f "$DATA_DIR/settings.yaml" ]
  then
    for key in $(yq e 'keys | .[]' "$DATA_DIR/settings.yaml"); do
      value=$(yq e ".\"$key\"" "$DATA_DIR/settings.yaml")
      export TF_VAR_$key="$value"
    done
  else
    echo -e "\033[0;31mFile variables.yaml is missing\033[0m\007"
    exit 1
  fi
else
  echo -e "\033[0;31mProfile does not exist\033[0m\007"
  exit 1
fi

cd $SCRIPT_DIR/terraform

terraform \
  destroy \
  -state="$DATA_DIR/terraform.tfstate" \
  -var="output_dir=$DATA_DIR" \
  --auto-approve

cd -

cd $DATA_DIR

rm -f config
rm -f inventory.txt
rm -f private_key.pem
rm -f terraform.tfstate*

cd -