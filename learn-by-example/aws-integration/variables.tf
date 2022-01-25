variable "datadog_api_url" {
  default = "https://api.datadoghq.com/"
}

variable "datadog_api_key" {
  sensitive = true
}

variable "datadog_app_key" {
  sensitive = true
}

variable "aws_account_id" {
  
}

variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "us-east-1"
}
