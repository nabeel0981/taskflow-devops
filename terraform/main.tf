terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "taskflow_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "taskflow-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.taskflow_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = { Name = "taskflow-public" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.taskflow_vpc.id
  tags = { Name = "taskflow-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.taskflow_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "taskflow_sg" {
  name   = "taskflow-sg"
  vpc_id = aws_vpc.taskflow_vpc.id

  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "taskflow-sg" }
}

resource "aws_instance" "taskflow_server" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.taskflow_sg.id]
  key_name               = "taskflow-key"

  user_data = <<-USERDATA
#!/bin/bash
set -e
exec > /var/log/user-data.log 2>&1

echo "=== Starting setup ==="
apt-get update -y

echo "=== Installing Docker ==="
curl -fsSL https://get.docker.com | sh
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

echo "=== Creating app directory ==="
mkdir -p /home/ubuntu/app
chown ubuntu:ubuntu /home/ubuntu/app

echo "=== Writing docker-compose.yml ==="
cat > /home/ubuntu/app/docker-compose.yml << 'COMPOSE'
services:
  taskflow:
    image: nabeeldevopsengineer/taskflow:latest
    container_name: taskflow
    ports:
      - "8090:8080"
    restart: unless-stopped

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped
COMPOSE

echo "=== Starting containers ==="
cd /home/ubuntu/app
docker compose up -d

echo "=== Setup complete ==="
USERDATA

  tags = { Name = "taskflow-server" }
}
