resource "aws_vpc" "aws_vpc" {
  cidr_block = var.aws_vpc_cidr
  tags = {
    Name = "AWS VPC"
  }
}