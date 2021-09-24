cd terraform
terraform apply --auto-approve
cd -

cd ansible
ansible-playbook -i inventory.txt os-setup.yaml --ssh-extra-args="-o IdentitiesOnly=yes"
ansible-playbook -i inventory.txt kubernetes.yaml --ssh-extra-args="-o IdentitiesOnly=yes"
ansible-playbook -i inventory.txt k8s-config.yaml --ssh-extra-args="-o IdentitiesOnly=yes"
cd -

kubectl config use-context kubernetes-admin@kubernetes
