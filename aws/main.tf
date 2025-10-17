terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.15"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Use Canonical AWS account ID for official Ubuntu images
  owners = ["099720109477"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.tag_name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.tag_name}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_name}-public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.tag_name}-private-${each.key}"
  }
}

locals {
  public_subnet_ids  = [for subnet in aws_subnet.public : subnet.id]
  private_subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  bastion_subnet_id  = local.public_subnet_ids[0]
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.tag_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = local.public_subnet_ids[0]

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.tag_name}-nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.tag_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.tag_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = local.private_subnet_ids[0]

  tags = {
    Name = var.tag_name
  }

  key_name = var.key_name

  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = false

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    encrypted   = true
  }

  metadata_options {
    # Use session tokens for accessing metadata
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
}

resource "aws_security_group" "bastion" {
  vpc_id      = aws_vpc.main.id
  name        = var.bastion_security_group_name
  description = "Bastion host security group"

  ingress {
    description = "SSH into bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_ssh_cidrs
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = local.bastion_subnet_id
  key_name                    = var.bastion_key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.bastion.id]

  tags = {
    Name = var.bastion_tag_name
  }

  root_block_device {
    volume_size = var.bastion_volume_size
    volume_type = var.volume_type
    encrypted   = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
}

resource "aws_security_group" "web" {
  vpc_id      = aws_vpc.main.id
  name        = var.security_group_name
  description = "Resource group"

  ingress {
    description = "Restrict SSH to known IP address range"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }

  ingress {
    description = "Restrict HTTPS to known IP address range"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    description = "Restrict outbound traffic to known IP address range"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = var.egress_cidrs
  }
}
