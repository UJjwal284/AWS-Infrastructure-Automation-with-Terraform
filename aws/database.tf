resource "aws_db_instance" "db_instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.34"
  instance_class         = "db.t2.micro"
  db_name                = "testDB"
  username               = var.RDS_USERNAME
  password               = var.RDS_PASSWORD
  parameter_group_name   = "default.mysql8.0"
  max_allocated_storage  = 100
  db_subnet_group_name   = aws_db_subnet_group.default.name
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.security_group_private.id]
  skip_final_snapshot    = true

  tags = {
    Name = "db-instance-tf"
  }
}