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
