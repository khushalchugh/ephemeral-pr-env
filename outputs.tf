output "public_ip_url" {
  value = "http://${aws_instance.ephemeral_instance.public_ip}"
}

output "public_dns" {
  value = aws_instance.ephemeral_instance.public_dns
}

output "instance_id" {
  value = aws_instance.ephemeral_instance.id
}
