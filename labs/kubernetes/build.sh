#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ ! -f $1.env ]
then
  echo -e "\033[0;31mEnv file does not exist\033[0m\007"
  ls  -1 *.env | xargs -n 1 basename
  exit 1
else
  source $1.env
  DDEXP_NAMESPACE=$1
fi

cd terraform

terraform workspace select -or-create=true $DDEXP_NAMESPACE
 
terraform apply --auto-approve \
  -var="region=$DDEXP_REGION" \
  -var="namespace=$DDEXP_NAMESPACE" \
  -var="creator=$DDEXP_CREATOR" \
  -var="workers_count=$DDEXP_WORKERS_COUNT" \
  -var="architecture=$DDEXP_ARCHITECTURE" \
  -var="features=$DDEXP_FEATURES"
cd -

cd ansible

ansible-playbook -i $DDEXP_NAMESPACE-inventory.txt os-setup.yaml \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e ansible_ssh_private_key_file=../terraform/$DDEXP_NAMESPACE-private_key.pem

ansible-playbook -i $DDEXP_NAMESPACE-inventory.txt cri-containerd.yaml \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e ansible_ssh_private_key_file=../terraform/$DDEXP_NAMESPACE-private_key.pem

ansible-playbook -i $DDEXP_NAMESPACE-inventory.txt kubernetes.yaml \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e kube_clustername=$DDEXP_NAMESPACE \
  -e kube_version=$DDEXP_KUBE_VERSION \
  -e cni=${DDEXP_CNI:-"calico"} \
  -e ansible_ssh_private_key_file=../terraform/$DDEXP_NAMESPACE-private_key.pem


if [[ "$DDEXP_FEATURES" == *"proxy"* ]]; then
  ansible-playbook -i $DDEXP_NAMESPACE-inventory.txt proxy.yaml \
    --ssh-extra-args="-o IdentitiesOnly=yes" \
    -e datadog_api_key=$DDEXP_DD_API_KEY \
    -e ansible_ssh_private_key_file=../terraform/$DDEXP_NAMESPACE-private_key.pem
fi

cd -

helm install aws-ebs-csi-driver \
    --namespace kube-system \
    aws-ebs-csi-driver/aws-ebs-csi-driver \
    --set controller.extraVolumeTags.Creator=$DDEXP_CREATOR

chmod 0600 ~/.kube/$DDEXP_NAMESPACE.config

zip -j9 $1.zip \
  ~/.kube/$DDEXP_NAMESPACE.config \
  terraform/$DDEXP_NAMESPACE-private_key.pem \
  ansible/$DDEXP_NAMESPACE-inventory.txt

rm ansible/$DDEXP_NAMESPACE-inventory.txt

