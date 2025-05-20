resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-client_name"
    client = "client_name"
    project = "quiz"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.101.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true  # Enable public IP assignment
  tags = {
    Name = "public_subnet_1"
    client = "client_name"
    project = "quiz"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.102.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true  # Enable public IP assignment
  tags = {
    Name = "public_subnet_2"
    client = "client_name"
    project = "quiz"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "private_subnet_1"
    client = "client_name"
    project = "quiz"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "private_subnet_2"
    client = "client_name"
    project = "quiz"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    client = "client_name"
    project = "quiz"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.regiao_aws}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  security_group_ids = [aws_security_group.private.id]

  private_dns_enabled = true


  tags = {
    client = "client_name"
    project = "quiz"
  }
}