terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1" # Change if you are not in US East
}

# 1. Create a Key Pair for SSH Access
resource "aws_key_pair" "deployer_key" {
  key_name   = "devops-project-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# 2. Create a Security Group (Firewall)
resource "aws_security_group" "web_sg" {
  name        = "devops_web_sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH Access
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTP Access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Create 2 EC2 Instances
resource "aws_instance" "app_server" {
  count         = 2
  ami           = "ami-04b70fa74e45c3917" # Ubuntu 24.04 LTS (us-east-1)
  instance_type = "t2.micro"              # Free tier eligible

  key_name               = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "DevOps-Node-Server-${count.index + 1}"
  }
}

# 4. Output the IP Addresses (We need these for Ansible)
output "instance_ips" {
  description = "Public IPs of the servers"
  value       = aws_instance.app_server[*].public_ip
}