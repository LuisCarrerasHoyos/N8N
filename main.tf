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

# Define variables for tags
variable "environment" {
  type    = string
  default = "dev"
  description = "Environment tag for all resources"
}

variable "owner" {
  type    = string
  default = "platform-team"
  description = "Owner tag for all resources"
}

# Define variables for EC2 instance
variable "ami" {
  type    = string
  default = "ami-0c55b2434c3a7b655" # Amazon Linux 2 AMI (eu-west-1)
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
  description = "Instance type for the EC2 instance"
}

# Create a security group that allows SSH access within the VPC only
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instance"

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Replace with your VPC CIDR block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ec2-security-group"
    Environment = var.environment
    Owner       = var.owner
  }
}

# Create an EC2 instance
resource "aws_instance" "ec2_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name        = "example-ec2-instance"
    Environment = var.environment
    Owner       = var.owner
  }
}