#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

source ${1:-kubeadm.env}

cd terraform
terraform apply --auto-approve \
  -state="$DDEXP_NAMESPACE.tfstate" \
  -var="region=$DDEXP_REGION" \
  -var="namespace=$DDEXP_NAMESPACE" \
  -var="creator=$DDEXP_CREATOR" \
  -var="workers_count=$DDEXP_WORKERS_COUNT"
cd -

cd ansible

KUBE_CLUSTERNAME=$DDEXP_NAMESPACE-kubeadm

ansible-playbook -i $DDEXP_NAMESPACE-inventory.txt os-setup.yaml \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e ansible_ssh_private_key_file=../terraform/$DDEXP_NAMESPACE-private_key.pem

ansible-playbook -i $DDEXP_NAMESPACE-inventory.txt cri-containerd.yaml \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e ansible_ssh_private_key_file=../terraform/$DDEXP_NAMESPACE-private_key.pem

ansible-playbook -i $DDEXP_NAMESPACE-inventory.txt kubernetes.yaml \
  --ssh-extra-args="-o IdentitiesOnly=yes" \
  -e kube_clustername=$DDEXP_NAMESPACE-kubeadm \
  -e kube_version=$DDEXP_KUBE_VERSION \
  -e ansible_ssh_private_key_file=../terraform/$DDEXP_NAMESPACE-private_key.pem
cd -

kubectl config rename-context kubernetes-admin@$DDEXP_NAMESPACE-kubeadm $DDEXP_NAMESPACE-kubeadm --kubeconfig ~/.kube/$KUBE_CLUSTERNAME.config
kubectl config use-context $DDEXP_NAMESPACE-kubeadm  --kubeconfig ~/.kube/$KUBE_CLUSTERNAME.config
