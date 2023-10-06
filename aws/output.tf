output "cloud_front_dsn_url" {
  value = "https://${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
}