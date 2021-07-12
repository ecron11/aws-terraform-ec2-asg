# Credentials
variable "aws_access_Key" {
  type = string
}

variable "aws_secret_Key" {
  type = string
}

variable "aws_key_name" {
  type = string
}

# Region and AZ settings
variable "availablity_zone" {
  type = string
}

# Networking

variable "vpc_CIDR" {
  type = string
}

variable "subnet_CIDR" {
  type = string
}

#Web Server
variable "web_server_private_ip" {
  type = string
}

variable "web_server_ami" {
  type = string
}

variable "web_server_instance_type" {
  type = string
}