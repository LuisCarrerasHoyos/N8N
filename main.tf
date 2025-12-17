# Define la versión mínima de Terraform y del proveedor AWS
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configura el proveedor AWS
provider "aws" {
  region = "eu-west-1"  # Región por defecto (Irlanda)
}

# Define las variables
variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2"
  default     = "t2.micro"
}

# Define el AMI (Amazon Machine Image) a usar.  Se recomienda buscar el AMI más reciente para la región.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Crea una instancia EC2
resource "aws_instance" "example_instance" {
  ami           = data.aws_ami.amazon_linux.id  # Usa el AMI obtenido
  instance_type = var.instance_type

  # Define las etiquetas (tags) para el recurso
  tags = {
    Environment = "dev"  # Valor por defecto
    Owner       = "platform-team"  # Valor por defecto
    Name        = "example-ec2-instance" # Nombre descriptivo
  }
}