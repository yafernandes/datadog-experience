terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

provider "datadog" {
  api_url = var.datadog_api_url
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

resource "datadog_integration_aws" "main" {
  account_id  = var.aws_account_id
  role_name   = "DatadogAWSIntegrationRole"
}

resource "aws_iam_role" "datadog" {
  name               = "DatadogAWSIntegrationRole"
  assume_role_policy = jsonencode(
    {
       Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::464622532012:root"
          }
          Action = "sts:AssumeRole"
          Condition = {
            StringEquals = {
              "sts:ExternalId" = datadog_integration_aws.main.external_id
            }
          }
        }
      ]
    }
  )

  inline_policy {
    name = "datadog-policy"
    policy = file("datadog-policy.json")
  }
}