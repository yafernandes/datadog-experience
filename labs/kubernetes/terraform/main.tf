provider "aws" {
  region  = var.region
  profile = "datadog"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "key_file" {
  filename        = "${var.namespace}-private_key.pem"
  file_permission = "600"
  content         = tls_private_key.ssh.private_key_pem
}

resource "aws_key_pair" "main" {
  public_key = tls_private_key.ssh.public_key_openssh
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "node" {
  name                = "${var.namespace}-node"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.namespace}-node"
  role = aws_iam_role.node.name
}

resource "aws_instance" "controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_types[var.architecture]
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.node.name

  root_block_device {
    volume_size = 13
  }

  tags = {
    Name     = "[${var.namespace}] controller"
    Creator  = var.creator
    dns_name = "controller"
  }

  volume_tags = {
    Name    = "[${var.namespace}] controller"
    Creator = var.creator
  }
}

resource "aws_instance" "worker" {
  count                  = var.workers_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_types[var.architecture]
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.node.name

  root_block_device {
    volume_size = 40
  }

  tags = {
    Name     = "[${var.namespace}] worker ${format("%02v", count.index)}"
    Creator  = var.creator
    dns_name = "worker${format("%02v", count.index)}"
  }

  volume_tags = {
    Name    = "[${var.namespace}] Worker ${format("%02v", count.index)}"
    Creator = var.creator
  }
}

resource "aws_instance" "proxy" {
  count                  = strcontains(var.features, "proxy") ? 1 : 0
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.key_name

  root_block_device {
    volume_size = 40
  }

  tags = {
    Name     = "[${var.namespace}] proxy"
    Creator  = var.creator
    dns_name = "proxy"
  }

  volume_tags = {
    Name    = "[${var.namespace}] Proxy"
    Creator = var.creator
  }
}

resource "aws_instance" "kali" {
  count                  = strcontains(var.features, "kali") ? 1 : 0
  ami                    = data.aws_ami.kali.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.key_name

  root_block_device {
    volume_size = 40
  }

  tags = {
    Name     = "[${var.namespace}] Kali"
    Creator  = var.creator
    dns_name = "kali"
  }

  volume_tags = {
    Name    = "[${var.namespace}] Kali"
    Creator = var.creator
  }
}

resource "local_file" "ansible_inventory" {
  content  = templatefile("inventory.tmpl", { controller = aws_instance.controller, workers = aws_instance.worker, namespace = var.namespace, domain = var.domain, features = var.features })
  filename = "../ansible/${var.namespace}-inventory.txt"
}
