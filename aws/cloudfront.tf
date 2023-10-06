resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_lb.load_balancer.dns_name
    custom_origin_config {
      http_port              = 8080
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      https_port             = 8080
    }
    origin_id = "origin-tf"
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-tf"
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = false
      cookies {
        forward = "all"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}