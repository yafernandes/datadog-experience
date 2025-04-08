variable "aws_region" {}

variable "aws_profile" {}

variable "owner" {}

variable "team" {
  default = "lab"
}

variable "kube_clustername" {}

variable "domain" {}

variable "subdomain" {}

variable "workers_count" {
  default = 3
}

variable "architecture" {
  default = "x86_64"
  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "Invalid architecture. Valid options are x86_64 or arm64."
  }
}

variable "controller_instance_type" {}

variable "worker_instance_type" {}

variable "instance_types" {
  type = map(string)
  default = {
    "x86_64" = "t3a.large"
    "arm64"  = "t4g.large"
  }
}

variable "features" {
  default = "none"
}

variable "output_dir" {
  default = "."
}