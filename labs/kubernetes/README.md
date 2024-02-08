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

- Create `<namespace>.env` based on `kubeadm.env.template`. Below is an example you could call `jdoe.env`:

  ```bash
  DDEXP_CREATOR=john.doe
  DDEXP_REGION=us-east-1
  DDEXP_WORKERS_COUNT=1
  DDEXP_KUBE_VERSION=1.29.1
  DDEXP_ARCHITECTURE=arm64
  ```

### Building the K8s Environment

```bash
./build.sh <namespace>
```

### Destroying the Environment

```bash
./destroy.sh <namespace>
```

### Accessing the cluster

#### [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)

The process creates a [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) under `$HOME/.kube`. The file name will follow the pattern `<namespace>.config`.

By default, kubectl looks for a file named config in the $HOME/.kube directory. You can specify other kubeconfig files by [setting the KUBECONFIG environment](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/#set-the-kubeconfig-environment-variable) variable or by setting the `--kubeconfig` flag.

#### ssh

The process creates a new pair of ssh keys each time. The private key will be under `./terraform` and will follow the pattern `<namespace>-private_key.pem`. We use the `ubuntu` user. The hostnames are:

- controller.<namespace>.aws.pipsquack.ca
- worker[00-n].<namespace>.aws.pipsquack.ca

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

To bypass the check, update the `$HOME/.ssh/config` with...

```text
Host *.pipsquack.ca   # whichever domain being used
   StrictHostKeyChecking no
   UserKnownHostsFile /dev/null
```

#### Build does not complete successfully

If for any reason the build does *not* complete successfully, be sure to run the `./destroy.sh <namespace>` script afterwards.  This tears down any AWS resources that were created or leftover residuals.
