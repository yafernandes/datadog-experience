# Kubernetes

## Prerequesits

- Software
  - Terraform
  - Ansible
  - [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- The Terrform component assumes a [credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) file with a profile datadog. Currently using an AdmistratorAccess policy attached to the credential.
- Make sure to initialize Terraform directory with `terraform init`.
- Add the line below to `~/.bashrc`.

  ```bash
  export KUBECONFIG="$KUBECONFIG:$HOME/.kube/kubeadm.config"
  ```

- :warning: HIGHLY RECOMMENDED: Create `terraform/terraform.tfvars` with the entries below at minimum. Replace the values in `< >` to you personal values.

  ```terraform
  namespace = "<NAMESPACE>"
  creator = "<NAME>"
  region = "<REGION>"
  ```
