#!/bin/bash
set -euox pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
  apply \
  -state="$DATA_DIR/terraform.tfstate" \
  -var="output_dir=$DATA_DIR" \
  --auto-approve

cd -

cd $SCRIPT_DIR/ansible

ansible-playbook os-setup.yaml \
  -i "$DATA_DIR/inventory.txt" \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e "@$DATA_DIR/settings.yaml" \
  -e "ansible_ssh_private_key_file=$DATA_DIR/private_key.pem"

ansible-playbook cri-${TF_VAR_cri:-containerd}.yaml \
  -i "$DATA_DIR/inventory.txt" \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e "@$DATA_DIR/settings.yaml" \
  -e "ansible_ssh_private_key_file=$DATA_DIR/private_key.pem"

ansible-playbook kubernetes.yaml \
  -i "$DATA_DIR/inventory.txt" \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e "@$DATA_DIR/settings.yaml" \
  -e "ansible_ssh_private_key_file=$DATA_DIR/private_key.pem"

ansible-playbook proxy.yaml \
  -i "$DATA_DIR/inventory.txt" \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e "@$DATA_DIR/settings.yaml" \
  -e "ansible_ssh_private_key_file=$DATA_DIR/private_key.pem"

cd -

cd $DATA_DIR

export KUBECONFIG=$DATA_DIR/config

helm install aws-ebs-csi-driver \
    --namespace kube-system \
    aws-ebs-csi-driver/aws-ebs-csi-driver \
    --set controller.extraVolumeTags.Creator=$TF_VAR_owner

if [ -f $DATA_DIR/secrets.yaml ]
then
  kubectl apply -f $DATA_DIR/secrets.yaml
  if [ -f $DATA_DIR/datadog-values.yaml ]
  then
    helm install datadog datadog/datadog -n datadog -f $DATA_DIR/datadog-values.yaml
  fi  
fi

zip "cluster_$(date +"%Y%m%d_%H%M%S").zip" config inventory.txt private_key.pem terraform.tfstate settings.yaml

cd -

for script in $(find "$DATA_DIR/init" -maxdepth 1 -type f -perm -100 | sort); do
  kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=300s
  "$script"
done
