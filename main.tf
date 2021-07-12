provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_Key
  secret_key = var.aws_secret_Key
}

# VPC
resource "aws_vpc" "production" {
  cidr_block = var.vpc_CIDR
  enable_dns_hostnames = true
  tags = {
    Name = "production"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.production.id
  tags = {
      Name = "prod-igw"
  }
}

# Subnet
resource "aws_subnet" "web-server-subnet" {
  vpc_id = aws_vpc.production.id
  cidr_block = var.subnet_CIDR
  availability_zone = var.availablity_zone

  tags = {
    "Name" = "web-server-subnet"
  }
}

# Route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.production.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }

  tags = {
    Name = "prod-route-table"
  }
}

# Subnet association
resource "aws_route_table_association" "web-server-subnet-association" {
  route_table_id = aws_route_table.prod-route-table.id
  subnet_id = aws_subnet.web-server-subnet.id
}

# Security group
resource "aws_security_group" "web-server-sec-group" {
  name="web-server-sec-group"
  description = "Allows web and ssh traffic"
  vpc_id = aws_vpc.production.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "Inbound HTTP"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "Inbound HTTPS"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
    description = "Inbound SSH"
  }
  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "allow all outbound traffic"
    from_port = 0
    protocol = "-1"
    to_port = 0
    ipv6_cidr_blocks = ["::/0"]
  }
}
# Network interface
resource "aws_network_interface" "web-server-eni" {
  security_groups = [ aws_security_group.web-server-sec-group.id ]
  subnet_id = aws_subnet.web-server-subnet.id
  private_ips = [var.web_server_private_ip]
}

#Elastic IP
resource "aws_eip" "web-server-eip" {
  vpc = true
  network_interface = aws_network_interface.web-server-eni.id
  associate_with_private_ip = var.web_server_private_ip
  depends_on = [
    aws_internet_gateway.prod-igw,
    aws_instance.web-server
  ]
}
# EC2 instance
resource "aws_instance" "web-server" {
  ami           = var.web_server_ami
  instance_type = var.web_server_instance_type
  key_name = var.aws_key_name
  availability_zone = var.availablity_zone
  network_interface {
    network_interface_id = aws_network_interface.web-server-eni.id
    device_index = 0
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install httpd -y
              sudo systemctl start httpd
              sudo bash -c 'echo Terraform'd Web Server > /var/www/html/index.html'
              EOF
  tags = {
    Name = "Ubuntu-Server"
  }
}