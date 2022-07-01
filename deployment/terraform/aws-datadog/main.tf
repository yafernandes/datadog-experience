terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_profile
}

data "aws_caller_identity" "current" {}

####
# https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/integration_aws
####
resource "datadog_integration_aws" "account" {
  account_id  = data.aws_caller_identity.current.account_id
  role_name   = var.datadog_role
}

resource "aws_iam_policy" "datadog" {
  path        = "/"
  description = "https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation#datadog-aws-iam-policy"

  policy = file("policy-datadog.json")

  tags = {
    creator = data.aws_caller_identity.current.arn
  }
}

resource "aws_iam_role" "datadog" {
  name = var.datadog_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::464622532012:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = datadog_integration_aws.account.external_id
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "datadog" {
  role       = aws_iam_role.datadog.name
  policy_arn = aws_iam_policy.datadog.arn
}

