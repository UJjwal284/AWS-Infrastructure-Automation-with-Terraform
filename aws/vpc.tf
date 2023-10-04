resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "vpc-tf"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "route-table-tf"
  }
}

resource "aws_subnet" "subnet_public1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "us-east-2a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    name = "subnet-public-1-tf"
  }
}

resource "aws_route_table_association" "route_table_association1" {
  subnet_id      = aws_subnet.subnet_public1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_subnet" "subnet_public2" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-2b"
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    name = "subnet-public-2-tf"
  }
}

resource "aws_route_table_association" "route_table_association2" {
  subnet_id      = aws_subnet.subnet_public2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_subnet" "subnet_private1" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-2a"
  cidr_block        = "10.0.3.0/24"

  tags = {
    name = "subnet-private-1-tf"
  }
}

resource "aws_subnet" "subnet_private2" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-2b"
  cidr_block        = "10.0.4.0/24"

  tags = {
    name = "subnet-private-2-tf"
  }
}

