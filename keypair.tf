resource "aws_key_pair" "deployer" {
  key_name   = "mack-deployer-key"
  public_key = "${var.public_key}"
}
