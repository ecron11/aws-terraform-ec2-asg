output "web-server-ip" {
  value = aws_eip.web-server-eip.public_ip
}

output "web-server-dns" {
  value = aws_eip.web-server-eip.public_dns
}