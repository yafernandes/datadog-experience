
resource "aws_cloudformation_stack" "datadog-forwarder" {
  name = "datadog-forwarder"

  capabilities = ["CAPABILITY_IAM"]

  parameters = {
    DdApiKey          = var.datadog_api_key
    DdApiKeySecretArn = "arn:aws:secretsmanager:DEFAULT"
    DdSite            = "datadoqhq.com"

  }

  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
}

resource "datadog_integration_aws_lambda_arn" "datadog-forwarder" {
  account_id = var.awsAccount
  lambda_arn = aws_cloudformation_stack.datadog-forwarder.outputs.DatadogForwarderArn
}