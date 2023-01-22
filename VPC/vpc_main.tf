#------------------VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example" {
  count      = 2
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.${count.index}.0/24"
  #availability_zone       = "${var.region}a, ${var.region}b"
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "example-subnet-${count.index + 1}"
  }
}
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "public" {
  #count                   = 2
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = 2
  subnet_id      = aws_subnet.example[count.index].id
  route_table_id = aws_route_table.public.id
}