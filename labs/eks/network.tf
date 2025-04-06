resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "EKS VPC"
    Owner     = var.owner
    CreatedBy = "Terrform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name      = "EKS Gateway"
    Owner     = var.owner
    CreatedBy = "Terrform"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                                 = "eks-public-${count.index}"
    Owner                                                = var.owner
    CreatedBy                                            = "Terrform"
    "kubernetes.io/role/elb"                             = "1"
    "kubernetes.io/cluster/${aws_eks_cluster.main.name}" = "shared"
  }
}

resource "aws_subnet" "private" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index + 100)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name      = "eks-private-${count.index}"
    Owner     = var.owner
    CreatedBy = "Terrform"

    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/my-eks"    = "shared"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name      = "eks-nat"
    Owner     = var.owner
    CreatedBy = "Terrform"

  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name      = "eks-public-rt"
    Owner     = var.owner
    CreatedBy = "Terrform"

  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name      = "eks-private-rt"
    Owner     = var.owner
    CreatedBy = "Terrform"

  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
