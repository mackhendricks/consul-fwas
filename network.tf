resource "aws_vpc" "main" {
  cidr_block = var.vpc_CIDR
  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_subnet" "Management-Subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.management_CIDR
  availability_zone = data.aws_availability_zones.available.names[0]

}
resource "aws_subnet" "Outside-Subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_CIDR
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.vpc_name}-Outside-Subnet"
  }
}
resource "aws_subnet" "Inside-Subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_CIDR
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.vpc_name} Inside Subnet"
  }
}

resource "aws_internet_gateway" "Internet-Gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.vpc_name} Internet Gateway"
  }
}

resource "aws_route_table" "Route-Table-Outside" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "Default-Route" {
  route_table_id         = aws_route_table.Route-Table-Outside.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Internet-Gateway.id
}
resource "aws_route_table_association" "Route-Table-Association-Management" {
  subnet_id      = aws_subnet.Management-Subnet.id
  route_table_id = aws_route_table.Route-Table-Outside.id
}
resource "aws_route_table_association" "Route-Table-Association-Outside" {
  subnet_id      = aws_subnet.Outside-Subnet.id
  route_table_id = aws_route_table.Route-Table-Outside.id
}

resource "aws_route_table" "Route-Table-Inside" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.vpc_name} Inside Route Table"
  }
}
resource "aws_route_table_association" "Route-Table-Association-Inside" {
  subnet_id      = aws_subnet.Inside-Subnet.id
  route_table_id = aws_route_table.Route-Table-Inside.id
}
