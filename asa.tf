resource "aws_network_interface" "ASAv-Management" {
  subnet_id         = aws_subnet.Management-Subnet.id
  security_groups   = [aws_security_group.SG-Allow-All.id]
  source_dest_check = false
  private_ips_count = 0
  private_ips       = ["${var.management_IP}"]
  tags = {
    "Name" = "ASAv-Management"
  }
}
resource "aws_network_interface" "ASAv-Outside" {
  subnet_id         = aws_subnet.Outside-Subnet.id
  security_groups   = [aws_security_group.SG-Allow-All.id]
  source_dest_check = false
  private_ips_count = 0
  private_ips       = [var.public_IP]
  tags = {
    "Name" = "ASAv-Outside"
  }
}
resource "aws_network_interface" "ASAv-Inside" {
  subnet_id         = aws_subnet.Inside-Subnet.id
  security_groups   = [aws_security_group.SG-Allow-All.id]
  source_dest_check = false
  private_ips_count = 0
  private_ips       = [var.private_IP]
  tags = {
    "Name" = "ASAv-Inside"
  }
}


resource "aws_eip" "Management-EIP" {
  vpc        = true
  depends_on = [aws_vpc.main, aws_internet_gateway.Internet-Gateway]
  tags = {
    "Name" = "ASAv Management IP"
  }
}
resource "aws_eip" "Outside-EIP" {
  vpc        = true
  depends_on = [aws_vpc.main, aws_internet_gateway.Internet-Gateway]
  tags = {
    "Name" = "ASAv Outside IP"
  }
}
resource "aws_eip_association" "Management-EIP-Association" {
  network_interface_id = aws_network_interface.ASAv-Management.id
  allocation_id        = aws_eip.Management-EIP.id
}
resource "aws_eip_association" "Outside-EIP-Association" {
  network_interface_id = aws_network_interface.ASAv-Outside.id
  allocation_id        = aws_eip.Outside-EIP.id
}

data "template_file" "asa_config" {
  template = "${file("./templates/asa_config.tpl")}"

  vars = {
    userdata_owner = "${var.owner}"

  }

}

resource "aws_instance" "ASAv" {
  ami           = var.ami_id
  instance_type = var.instance_size
  key_name      = var.key_pair
  user_data     = data.template_file.asa_config.rendered
  tags = {
    Name  = "${var.owner}-cisco-asav"
    owner = "var.owner"
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ASAv-Management.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.ASAv-Outside.id
  }

  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.ASAv-Inside.id
  }


}
