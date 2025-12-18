# Definición del proveedor AWS y versión
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# Configuración del proveedor AWS
provider "aws" {
  region = "eu-west-1" # Región por defecto: Irlanda
}

# Variable para el entorno
variable "environment" {
  type    = string
  default = "dev" # Valor por defecto: dev
}

# Variable para el owner
variable "owner" {
  type    = string
  default = "platform-team" # Valor por defecto: platform-team
}

# Variable para mi IP de acceso SSH
variable "my_ip" {
  type    = string
  default = "0.0.0.0/0" #RECUERDA CAMBIAR ESTO POR TU IP REAL
  description = "Tu IP para acceso SSH"
}

# Crear VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "company-vpc"
    Environment = var.environment
    Owner       = var.owner
  }
}

# Crear Security Group
resource "aws_security_group" "instance" {
  name        = "instance-sg"
  description = "Permite acceso SSH desde una IP específica."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from specific IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] #Solo permitir acceso SSH desde mi IP
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

# Buscar la AMI de Ubuntu 22.04
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

# Crear instancia EC2
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Tipo de instancia por defecto: t3.micro
  vpc_security_group_ids = [
    aws_security_group.instance.id,
  ]
  key_name = "company-key" # Usar clave SSH "company-key"
  subnet_id = aws_vpc.main.id

  tags = {
    Name        = "app-server"
    Environment = var.environment
    Owner       = var.owner
  }
}