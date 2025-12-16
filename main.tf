```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "ec2_dev_instance" {
  ami           = "ami-0c5204531f799e0c6" # AMI de Amazon Linux 2 en eu-west-1 (Irlanda)
  instance_type = "t3.micro"

  tags = {
    Environment = "dev"
    Owner       = "platform-team"
  }
}
```