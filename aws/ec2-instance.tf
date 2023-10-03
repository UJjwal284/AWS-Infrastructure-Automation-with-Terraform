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