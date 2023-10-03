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