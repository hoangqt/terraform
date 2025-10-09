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

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = var.tag_name
  }

  key_name = var.key_name

  vpc_security_group_ids = [aws_security_group.web.id]

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

resource "aws_security_group" "web" {
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
