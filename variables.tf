data "aws_availability_zones" "available" {}
variable "region" {
  default = "us-east-1"
}
variable "instance_size" {
  default = "c4.large"
}

variable "ami_id" {
  // ASA version  9.12(2)
  default = "ami-01b0bfec54ba93d12"
}


variable "key_pair" {}
variable "public_key" {}
variable "management_CIDR" {}
variable "management_IP" {}
variable "private_CIDR" {}
variable "private_IP" {}
variable "public_CIDR" {}
variable "public_IP" {}
variable "vpc_name" {}
variable "vpc_CIDR" {}
variable "consul_faas_mgmt_IP" {}

# The AWS username of the owner. Used for tagging resources

variable "owner" {}

// If you have multiple AWS Accounts you can specify which profile to use

variable "aws_profile" {}
