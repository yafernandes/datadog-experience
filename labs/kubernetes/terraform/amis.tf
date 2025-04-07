
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connection-prereqs.html
# aws ec2 describe-images --owners 136693071363 --filters "Name=name,Values=debian-11-*" "Name=architecture,Values=x86_64" --query 'sort_by(Images, &CreationDate)[]' --region us-east-1 | jq
# aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/*" "Name=architecture,Values=x86_64" --query 'sort_by(Images, &CreationDate)[]' --region us-east-1 | jq
data "aws_ami" "ubuntu" {
  owners      = ["amazon"]
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/*"]
  }

  filter {
    name   = "name"
    values = ["*22.04*"]
  }
  filter {
    name   = "architecture"
    values = [var.architecture]
  }

}

# data "aws_ami" "centos" {
#   owners      = ["125523088429"]
#   most_recent = "true"

#   filter {
#     name   = "name"
#     values = ["CentOS 7.9*"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }

data "aws_ami" "debian" {
  owners      = ["136693071363"]
  most_recent = "true"

  filter {
    name   = "name"
    values = ["debian-11-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "rehl" {
  owners      = ["309956199498"]
  most_recent = "true"

  filter {
    name   = "name"
    values = ["RHEL-8.4*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "kali" {
  owners      = ["679593333241"]
  most_recent = "true"

  filter {
    name   = "description"
    values = ["Kali Linux kali-last-snapshot *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# data "aws_ami" "windows2019" {
#   owners      = ["801119661308"]
#   most_recent = "true"

#   filter {
#     name   = "name"
#     values = ["Windows_Server-2019-English-Core-Containers*"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }
