resource "aws_security_group" "security_group_public" {
  name        = "security-group-public-tf"
  description = "Public Security Group for TF"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = [80, 8080, 22]
    iterator = port
    content {
      from_port   = port.value
      protocol    = "tcp"
      to_port     = port.value
      cidr_blocks = ["0.0.0.0/0"]
    }
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

resource "aws_security_group" "security_group_private" {
  name        = "security-group-private-tf"
  description = "Private Security Group for TF"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = [3306]
    iterator = port
    content {
      from_port       = port.value
      protocol        = "tcp"
      to_port         = port.value
      security_groups = [aws_security_group.security_group_public.id]
    }
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "security-group-private-tf"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.subnet_private1.id, aws_subnet.subnet_private2.id]

  tags = {
    Name = "My DB subnet group"
  }
}