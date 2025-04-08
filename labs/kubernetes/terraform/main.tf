provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "key_file" {
  filename        = "${var.output_dir}/private_key.pem"
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
  name               = "${var.subdomain}-node"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "EBSCSIDriver" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.subdomain}-node"
  role = aws_iam_role.node.name
}

resource "aws_instance" "controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.controller_instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.node.name

  root_block_device {
    volume_size = 13
  }

  tags = {
    Name                                            = "[${var.subdomain}] controller"
    Owner                                           = var.owner
    Team                                            = var.team
    CreatedBy                                       = "Terrform"
    "kubernetes.io/cluster/${var.kube_clustername}" = "owned"
    dns_name                                        = "controller"
  }

  volume_tags = {
    Name                                            = "[${var.subdomain}] controller"
    Owner                                           = var.owner
    Team                                            = var.team
    CreatedBy                                       = "Terrform"
    "kubernetes.io/cluster/${var.kube_clustername}" = "owned"
    CreatedBy                                       = "Terrform"
  }
}

resource "aws_instance" "worker" {
  count                  = var.workers_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.node.name

  root_block_device {
    volume_size = 40
  }

  tags = {
    Name                                            = "[${var.subdomain}] worker ${format("%02v", count.index)}"
    Owner                                           = var.owner
    Team                                            = var.team
    CreatedBy                                       = "Terrform"
    "kubernetes.io/cluster/${var.kube_clustername}" = "owned"
    dns_name                                        = "worker${format("%02v", count.index)}"
  }

  volume_tags = {
    Name                                            = "[${var.subdomain}] Worker ${format("%02v", count.index)}"
    Owner                                           = var.owner
    Team                                            = var.team
    CreatedBy                                       = "Terrform"
    "kubernetes.io/cluster/${var.kube_clustername}" = "owned"
    Team                                            = var.team
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
    Name      = "[${var.subdomain}] proxy"
    Owner     = var.owner
    Team      = var.team
    CreatedBy = "Terrform"
    dns_name  = "proxy"
  }

  volume_tags = {
    Name      = "[${var.subdomain}] Proxy"
    Owner     = var.owner
    CreatedBy = "Terrform"
    Team      = var.team
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
    Name      = "[${var.subdomain}] Kali"
    Owner     = var.owner
    Team      = var.team
    CreatedBy = "Terrform"
    dns_name  = "kali"
  }

  volume_tags = {
    Name      = "[${var.subdomain}] Kali"
    Owner     = var.owner
    Team      = var.team
    CreatedBy = "Terrform"
  }
}

resource "local_file" "ansible_inventory" {
  content              = templatefile("inventory.tmpl", { controller = aws_instance.controller, workers = aws_instance.worker, subdomain = var.subdomain, domain = var.domain, features = var.features })
  filename             = "${var.output_dir}/inventory.txt"
  directory_permission = 666
}
