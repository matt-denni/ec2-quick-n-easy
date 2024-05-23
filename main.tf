terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 1.8.3"
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

resource "aws_security_group" "sg_outbound" {
  name        = "all-outbound"
  description = "Allow all outbound traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ssh" {
  name        = "ssh-inbound"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_http" {
  name        = "http-inbound"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_server" {
  ami               = "ami-0c7217cdde317cfec"
  instance_type     = "t2.micro"
  key_name          = aws_key_pair.my_key_pair.key_name
  security_groups   = [aws_security_group.sg_ssh.name, aws_security_group.sg_outbound.name, aws_security_group.sg_http.name]
  user_data = <<-EOF
              #!/bin/bash
              curl -fsSL https://get.docker.com -o get-docker.sh
              chmod +x get-docker.sh
              ./get-docker.sh
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              docker run -d -p 80:80 nginx
              EOF
}

output "instance_public_ip" {
  value = aws_instance.my_server.public_ip
}

output "ssh_private_key" {
  value = tls_private_key.pk.private_key_openssh
  sensitive = true
}
