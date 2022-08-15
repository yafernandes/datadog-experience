variable "datadog_api_key" {}

variable "datadog_app_key" {}

variable "datadog_role" {
  description = "Datadog role created for AWS Integration"
  default     = "datadog"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "default"
}

variable "cspm_resource_collection_enabled" {
  default = true
}

variable "resource_collection_enabled" {
  default = true
}

#enable cspm
variable "enable_cspm" {
  default = true
}

#AWS secrity audit policy for Datadog cspm
variable "aws_security_audit_policy"{
  default = "arn:aws:iam::aws:policy/SecurityAudit"
}
