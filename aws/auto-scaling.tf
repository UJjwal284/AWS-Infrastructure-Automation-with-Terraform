resource "aws_launch_configuration" "launch_configuration" {
  name_prefix     = "ec2-tf-"
  image_id        = "ami-0d406e26e5ad4de53"
  instance_type   = "t2.micro"
  key_name        = "test-key"
  security_groups = [aws_security_group.security_group_public.id]
  user_data       = <<-EOF
              #!/bin/bash
              wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
              sudo yum -y install ./jdk-17_linux-x64_bin.rpm
              java -version
              wget https://tf-app-1.s3.us-east-2.amazonaws.com/app.jar
              nohup java -jar app.jar > output.log 2>&1 &
              sleep 4
              EOF
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "autoscaling-group-tf"
  desired_capacity          = 2
  max_size                  = 5
  min_size                  = 1
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  launch_configuration      = aws_launch_configuration.launch_configuration.name
  vpc_zone_identifier       = [aws_subnet.subnet_public1.id, aws_subnet.subnet_public2.id]
  target_group_arns         = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "autoscaling_policy" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
  name                   = "autoscaling-policy-tf"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 100
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "example-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 10
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Scale up when CPU exceeds 20%"
  alarm_actions       = [aws_autoscaling_policy.autoscaling_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }
}