output "dns_url" {
  value = "http://${aws_lb.load_balancer.dns_name}:8080"
}