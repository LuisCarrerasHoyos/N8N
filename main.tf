terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# Define variables
variable "environment" {
  type    = string
  default = "dev"
  description = "Environment (dev, staging, prod)"
}

variable "owner" {
  type    = string
  default = "platform-team"
  description = "Owner of the resource"
}

variable "allowed_ssh_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/16"] # Reemplazar por las IPs reales permitidas
  description = "List of CIDR blocks allowed to connect via SSH"
}

# Data source to retrieve the Ubuntu 22.04 AMI
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

  owners = ["099720109477"] # Canonical
}

# Security Group to allow SSH access
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Allow SSH access from specific IPs"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
    description = "SSH access from allowed IPs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "instance-sg"
    Environment = var.environment
    Owner       = var.owner
  }
}

# EC2 Instance
resource "aws_instance" "example" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "company-key"
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  # Do not assign a public IP by default
  associate_public_ip_address = false

  tags = {
    Name        = "example-instance"
    Environment = var.environment
    Owner       = var.owner
  }
}