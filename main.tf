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

# Define variables for common values
variable "environment" {
  type    = string
  default = "dev"
  description = "Environment for the EC2 instance (e.g., dev, staging, prod)"
}

variable "owner" {
  type    = string
  default = "platform-team"
  description = "Owner of the EC2 instance"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
  description = "EC2 instance type"
}

variable "ami_id" {
  type    = string
  default = "ami-0c55b35dcd4253988" # This is a public AMI for testing purposes - Ubuntu 22.04 LTS - eu-west-1. Replace with a suitable, hardened AMI for production.
  description = "AMI ID for the EC2 instance"
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = "example-instance"
    Environment = var.environment
    Owner       = var.owner
  }
}