
/*
resource "aws_nat_gateway" "ngw" {
  count         = length(var.azs)
  allocation_id = element(aws_eip.nat-eip.*.id, count.index)

  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)

  tags = {
    Name = "Nat Gateway - ${count.index + 1}"
  }
}

resource "aws_eip" "nat-eip" {
  count  = length(var.azs)
  domain = "vpc"
  tags = {
    Name = "EIP - ${count.index + 1}"
  }
}
*/