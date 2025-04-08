data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "http" "dd_ip_ranges" {
  url = "https://ip-ranges.datadoghq.com/"
}

data "aws_availability_zones" "available" {
  state            = "available"
  exclude_zone_ids = ["us-west-2d"]
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                            = "${var.subdomain} Kubernetes"
    Owner                                           = var.owner
    Team                                            = var.team
    CreatedBy                                       = "Terrform"
    "kubernetes.io/cluster/${var.kube_clustername}" = "owned"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[0]
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "${var.subdomain} Kubernetes"
    Owner                                           = var.owner
    Team                                            = var.team
    CreatedBy                                       = "Terrform"
    "kubernetes.io/cluster/${var.kube_clustername}" = "owned"
  }
}

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  name   = "main_security_group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    self        = true
  }

  // Datadog synthetics origins
  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = jsondecode(data.http.dd_ip_ranges.response_body).synthetics.prefixes_ipv4
  #   self        = true
  # }

  // Datadog synthetics origins
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = jsondecode(data.http.dd_ip_ranges.response_body).synthetics.prefixes_ipv4_by_location["aws:us-east-1"]
    self        = true
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = jsondecode(data.http.dd_ip_ranges.response_body).synthetics.prefixes_ipv4_by_location["aws:us-east-2"]
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                            = "${var.subdomain} Kubernetes"
    Owner                                           = var.owner
    Team                                            = var.team
    CreatedBy                                       = "Terrform"
    "kubernetes.io/cluster/${var.kube_clustername}" = "owned"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name                                            = "${var.subdomain} Kubernetes"
    Owner                                           = var.owner
    Team                                            = var.team
    CreatedBy                                       = "Terrform"
    "kubernetes.io/cluster/${var.kube_clustername}" = "owned"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name                                            = "${var.subdomain} Kubernetes"
    Owner                                           = var.owner
    Team                                            = var.team
    CreatedBy                                       = "Terrform"
    "kubernetes.io/cluster/${var.kube_clustername}" = "owned"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
