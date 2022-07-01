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

resource "aws_s3_bucket" "archive" {
  force_destroy = true
  tags = {
    Name    = "Datadog Archive"
    Creator = data.aws_caller_identity.current.arn
  }
}

resource "aws_s3_bucket_public_access_block" "archive" {
  bucket                  = aws_s3_bucket.archive.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "log-archiving" {
  name        = "log-archiving"
  path        = "/"
  description = "https://docs.datadoghq.com/logs/archives/?tab=awss3#set-permissions"

  policy = templatefile("policy-log-archiving.json.tftpl", { bucket = aws_s3_bucket.archive.id })

  tags = {
    creator = data.aws_caller_identity.current.arn
  }
}

resource "aws_iam_role_policy_attachment" "log-archiving" {
  role       = var.datadog_role
  policy_arn = aws_iam_policy.log-archiving.arn
}

resource "datadog_logs_archive" "my_s3_archive" {
  name  = "Main archive"
  query = "host:*.alexf.aws.pipsquack.ca"
  s3_archive {
    bucket     = aws_s3_bucket.archive.id
    path       = "/archive"
    account_id = data.aws_caller_identity.current.account_id
    role_name  = var.datadog_role
  }
}
