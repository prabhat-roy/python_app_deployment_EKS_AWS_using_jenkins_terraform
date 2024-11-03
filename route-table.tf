resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.aws_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}
/*
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.aws_vpc.id
  count  = length(var.private_subnet_cidrs)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw[count.index].id
  }

  tags = {
    Name = "Private Route Table ${count.index + 1}"
  }
}
*/