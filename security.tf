resource "aws_security_group" "SG-Allow-All" {
  name        = "SG-Allow-All"
  description = "Security Group to allow all traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "SG-Allow-All"
  }
}
