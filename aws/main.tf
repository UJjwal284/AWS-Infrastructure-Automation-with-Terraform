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

resource "aws_lb" "load_balancer" {
  name                       = "load-balancer-tf"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.security_group_public.id]
  subnets                    = [aws_subnet.subnet_public1.id, aws_subnet.subnet_public2.id]
  enable_deletion_protection = false
  enable_http2               = true
}

resource "aws_lb_target_group" "target_group" {
  name     = "target-group-tf"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "target_group_attachment1" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.ec2_machine1.id
}

resource "aws_lb_target_group_attachment" "target_group_attachment2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.ec2_machine2.id
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
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

resource "aws_route_table_association" "route_table_association1" {
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

resource "aws_instance" "ec2_machine1" {
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
      "wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm",
      "sudo yum -y install ./jdk-17_linux-x64_bin.rpm",
      "java -version",
      "wget https://tf-app-1.s3.us-east-2.amazonaws.com/app.jar",
      "nohup java -jar app.jar > output.log 2>&1 &",
      "sleep 4"
    ]
  }

  tags = {
    Name = "ec2-1-tf"
  }
}

resource "aws_instance" "ec2_machine2" {
  ami                         = "ami-0d406e26e5ad4de53"
  instance_type               = "t2.micro"
  key_name                    = "test-key"
  subnet_id                   = aws_subnet.subnet_public2.id
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
      "wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm",
      "sudo yum -y install ./jdk-17_linux-x64_bin.rpm",
      "java -version",
      "wget https://tf-app-1.s3.us-east-2.amazonaws.com/app.jar",
      "nohup java -jar app.jar > output.log 2>&1 &",
      "sleep 4"
    ]
  }

  tags = {
    Name = "ec2-2-tf"
  }
}

output "dns_url" {
  value = "http://${aws_lb.load_balancer.dns_name}:8080"
}