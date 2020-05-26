output "ip" {
  value = aws_eip.Management-EIP.public_ip
}
output "ssh_command" {
  value = "ssh admin@${aws_eip.Management-EIP.public_ip}"
}

output "docs_console" {
  value = "https://${aws_eip.Management-EIP.public_ip}/doc/"
}

output "fass_console" {
  value = "http://${aws_eip.consul_faas-EIP.public_ip}:5000"
}

output "consul_interface" {
  value = "http://${aws_eip.consul_faas-EIP.public_ip}:8500"
}
