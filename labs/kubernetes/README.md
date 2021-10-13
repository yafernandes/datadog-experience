# Kubernetes

This repository will create a Kuberntes cluster in AWS.
It will deploy the required infrastructure in AWS using Terraform.  Using Ansible, it will install and configure a Kubernetes cluster using [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).

## Prerequesits

- Software Requirements:
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
  - [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
  - [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- The Terrform component assumes an AWS [credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) file with a profile [datadog] is set.  Currently using an AdmistratorAccess policy attached to the credential.
- Make sure to initialize Terraform directory with `terraform init` in the `terraform` directory.
- Add the line below to `~/.bashrc` or which ever $SHELL being used.

  ```bash
  export KUBECONFIG="$KUBECONFIG:$HOME/.kube/kubeadm.config"
  ```

- :warning: HIGHLY RECOMMENDED: Create `terraform/terraform.tfvars` with the entries below at minimum. Replace the values in `< >` to you personal values.

  ```terraform
  namespace = "<NAMESPACE>"
  creator = "<NAME>"
  region = "<REGION>"
  domain = "<TOP_LEVEL_DOMAIN>"  // OPTIONAL - pipsquack.ca by default
  ```

### Building the K8s Environment

By default, the build.sh script will create one master and one worker node both are t2.large instance type.  If you would like to increase the number of worker nodes, you can edit the terraform/variables.tf file under the `workers_count` section and set the `default` to a higher number.

- `cd ./datadog-experience/labs/kubenetes` or where you cloned your repo
- `sh build.sh`

### Destroying the Environment

- `cd ./datadog-experience/labs/kubenetes` or where you cloned your repo
- `sh destroy.sh`

### Troubleshooting

#### Bypass SSH Host Fingerprint Check

- When running the `build.sh` the fingerprint host validation may start looping...

```text
The authenticity of host 'worker00.test-k8.pipsquack.ca (54.202.147.104)' can't be established.
ECDSA key fingerprint is SHA256:EaMdzQBtV7uZj2LrqGfmDqzCtsKjxkcfTszG6govsb0.
The authenticity of host 'master.test-k8.pipsquack.ca (34.219.196.72)' can't be established.
ECDSA key fingerprint is SHA256:U7FDgwKpRoy98rfGbQ18uOzLIx5QwVSd6KG+y8SAX8s.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Please type 'yes', 'no' or the fingerprint: yes
Please type 'yes', 'no' or the fingerprint: yes
Please type 'yes', 'no' or the fingerprint: yes
Please type 'yes', 'no' or the fingerprint: yes
Please type 'yes', 'no' or the fingerprint: yes

```

To bypass the check, update the `~/.ssh/config` with...

```text
Host *.pipsquack.ca   # whichever domain being used
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
```

#### Build does not complete successfully

If for any reason the build does *not* complete successfully, be sure to run the `sh destroy.sh` script afterwards.  This tears down any AWS resources that were created or leftover residuals.
