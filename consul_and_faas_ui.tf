resource "aws_network_interface" "consul_faas_mgmt" {
  subnet_id         = aws_subnet.Management-Subnet.id
  security_groups   = [aws_security_group.SG-Allow-All.id]
  source_dest_check = false
  private_ips_count = 0
  private_ips       = ["${var.consul_faas_mgmt_IP}"]
  tags = {
    "Name" = "Consul_and_Faas_Management"
  }
}

resource "aws_eip" "consul_faas-EIP" {
  vpc        = true
  depends_on = [aws_vpc.main, aws_internet_gateway.Internet-Gateway]
  tags = {
    "Name" = "Consul_Faas_Management IP"
  }
}
resource "aws_eip_association" "consul_faas-EIP-Association" {
  network_interface_id = aws_network_interface.consul_faas_mgmt.id
  allocation_id        = aws_eip.consul_faas-EIP.id
}

data "template_file" "consul_faas_config" {
  template = "${file("./templates/consul_faas.tpl")}"

  vars = {
    userdata_consul_faas_mgmt_IP= "${var.consul_faas_mgmt_IP}"
    userdata_asa_host_IP = "${aws_eip.Management-EIP.public_ip}"    
  }

}

resource "aws_instance" "Consul_FaaS" {
  ami           = "ami-066027b63b44ebc0a"
  instance_type = var.instance_size
  key_name      = var.key_pair
  user_data     = data.template_file.consul_faas_config.rendered
  tags = {
    Name  = "${var.owner}-consul_faas"
    owner = "var.owner"
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.consul_faas_mgmt.id
  }
}
