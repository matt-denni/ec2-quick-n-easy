terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "my_server_key"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "aws_security_group" "my_security_group" {
  name        = "my_server_sg"
  description = "Allow SSH inbound and all outbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_server" {
  ami               = "ami-0c7217cdde317cfec"
  instance_type     = "t2.micro"
  key_name          = aws_key_pair.my_key_pair.key_name
  security_groups   = [aws_security_group.my_security_group.name]
}

output "instance_public_ip" {
  value = aws_instance.my_server.public_ip
}

output "ssh_private_key" {
  value = tls_private_key.pk.private_key_openssh
  sensitive = true
}
