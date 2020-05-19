output "ip" {
  value = aws_eip.Management-EIP.public_ip
}
output "ssh_command" {
  value = "ssh admin@${aws_eip.Management-EIP.public_ip}"
}

output "docs_console" {
  value = "https://${aws_eip.Management-EIP.public_ip}/doc/"
}