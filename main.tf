terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# Data source to get the AMI ID for Ubuntu 22.04 in eu-west-1
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


# Security Group to allow SSH access from a specific IP
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Allow SSH traffic from specific IP"
  vpc_id      = "vpc-080270e59d1d18420" # Reemplaza con tu VPC ID. ¡¡¡IMPORTANTE!!!

  ingress {
    description = "SSH from specific IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["80.58.112.154/32"] # Reemplaza con tu IP publica/32. ¡¡¡IMPORTANTE!!!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "dev"
    Owner       = "platform-team"
  }
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "company-key" # Asegúrate de que esta clave exista en AWS

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name        = "example-instance"
    Environment = "dev"
    Owner       = "platform-team"
  }
}