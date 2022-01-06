#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd terraform
terraform apply --auto-approve
cd -

cd ansible
ansible-playbook -i inventory.txt os-setup.yaml --ssh-extra-args="-o IdentitiesOnly=yes"
ansible-playbook -i inventory.txt kubernetes.yaml --ssh-extra-args="-o IdentitiesOnly=yes"
cd -

kubectl config rename-context kubernetes-admin@kubernetes kubeadm
kubectl config use-context kubeadm
