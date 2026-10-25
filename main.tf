# ============================================================
# DeployFlow - Phase 2: AWS Infrastructure
# Builds: VPC, subnet, internet gateway, route table,
# security group, SSH key pair, and one free-tier EC2 server
# Cost: $0 (free tier). Run "terraform destroy" when done.
# ============================================================

provider "aws" {
  region = "ap-south-1"
}

# ---------- 1. NETWORK (VPC) ----------

resource "aws_vpc" "deployflow_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = { Name = "deployflow-vpc" }
}

# ---------- 2. SUBNET ----------

resource "aws_subnet" "deployflow_public_subnet" {
  vpc_id                  = aws_vpc.deployflow_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = { Name = "deployflow-public-subnet" }
}

# ---------- 3. INTERNET ACCESS ----------

resource "aws_internet_gateway" "deployflow_igw" {
  vpc_id = aws_vpc.deployflow_vpc.id

  tags = { Name = "deployflow-igw" }
}

resource "aws_route_table" "deployflow_rt" {
  vpc_id = aws_vpc.deployflow_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.deployflow_igw.id
  }

  tags = { Name = "deployflow-rt" }
}

resource "aws_route_table_association" "deployflow_rta" {
  subnet_id      = aws_subnet.deployflow_public_subnet.id
  route_table_id = aws_route_table.deployflow_rt.id
}

# ---------- 4. FIREWALL (SECURITY GROUP) ----------

resource "aws_security_group" "deployflow_sg" {
  name        = "deployflow-sg"
  description = "Allow SSH and app traffic only"
  vpc_id      = aws_vpc.deployflow_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "deployflow-sg" }
}

# ---------- 5. SSH KEY PAIR ----------

resource "tls_private_key" "deployflow_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployflow_keypair" {
  key_name   = "deployflow-key"
  public_key = tls_private_key.deployflow_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.deployflow_key.private_key_pem
  filename        = "${path.module}/deployflow-key.pem"
  file_permission = "0600"
}

# ---------- 6. FIND LATEST UBUNTU IMAGE ----------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ---------- 7. THE SERVER (EC2) ----------

resource "aws_instance" "deployflow_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.deployflow_public_subnet.id
  vpc_security_group_ids = [aws_security_group.deployflow_sg.id]
  key_name               = aws_key_pair.deployflow_keypair.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              usermod -aG docker ubuntu
              systemctl enable docker
              systemctl start docker
              EOF

  tags = { Name = "deployflow-server" }
}

# ---------- OUTPUTS ----------

output "server_public_ip" {
  description = "Public IP of your server"
  value       = aws_instance.deployflow_server.public_ip
}

output "ssh_command" {
  description = "Command to log into your server"
  value       = "ssh -i deployflow-key.pem ubuntu@${aws_instance.deployflow_server.public_ip}"
}
