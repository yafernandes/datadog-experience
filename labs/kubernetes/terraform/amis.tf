
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connection-prereqs.html
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
