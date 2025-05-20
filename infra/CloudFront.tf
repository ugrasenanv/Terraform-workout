resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "project_name-quiz-1000heads.s3.eu-west-2.amazonaws.com"
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = "project_name-quiz-1000heads.s3.eu-west-2.amazonaws.com"
    origin_id   = "EC2Origin"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.1", "TLSv1.2"]
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for EC2 instance and S3 bucket"
  default_root_object = "main.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "EC2Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/static/*"
    target_origin_id = "S3Origin"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  ordered_cache_behavior {
  path_pattern     = "/media/*"
  target_origin_id = "S3Origin"

  allowed_methods  = ["GET", "HEAD"]
  cached_methods   = ["GET", "HEAD"]

  forwarded_values {
    query_string = false
    cookies {
      forward = "none"
    }
  }
  viewer_protocol_policy = "redirect-to-https"
  min_ttl                = 0
  default_ttl            = 3600
  max_ttl                = 86400
  }
  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  tags = {
    client  = "client_name"                         
    project = "quiz"
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for S3 bucket"
  
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}