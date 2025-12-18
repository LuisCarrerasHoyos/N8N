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

# Define variables for tags and instance type
variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "platform-team"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
  description = "EC2 Instance Type"
}

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}


# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = {
    Name        = "example-instance"
    Environment = var.environment
    Owner       = var.owner
  }
}