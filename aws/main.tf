provider "aws" {
  region     = "us-east-2"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "vpc-tf"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway-tf"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "route-table-tf"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
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

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet_public1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_subnet" "subnet_public2" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-2b"
  cidr_block        = "10.0.2.0/24"

  tags = {
    name = "subnet-public-2-tf"
  }
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

resource "aws_security_group" "security_group_public" {
  name        = "security-group-public-tf"
  description = "Public Security Group for TF"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "security-group-public-tf"
  }
}

resource "aws_instance" "ec2_machine" {
  ami                         = "ami-0d406e26e5ad4de53"
  instance_type               = "t2.micro"
  key_name                    = "test-key"
  subnet_id                   = aws_subnet.subnet_public1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security_group_public.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("secret/test-key.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "echo 'Hello, World!' | sudo tee /var/www/html/index.html",
      "sudo service httpd start",
    ]
  }

  tags = {
    Name = "ec2-tf"
  }
}

