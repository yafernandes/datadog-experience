variable "creator" {}

variable "namespace" {}

variable "region" {}

variable "features" {
  default = "none"
}

variable "domain" {
  default = "aws.pipsquack.ca"
}

variable "workers_count" {}

variable "architecture" {
  default = "x86_64"
  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "Invalid architecture. Valid options are amd64 or arm64."
  }
}

variable "instance_types" {
  type = map(string)
  default = {
    "x86_64" = "t3a.large"
    "arm64" = "t4g.large"
  }
}