locals {
  s3_origin_id = var.origin_type == "s3" ? var.origin_id : null
  alb_origin_id = var.origin_type == "alb" ? var.origin_id : null
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.environment} CloudFront Distribution"
  default_root_object = "index.html"
  price_class         = var.price_class
  aliases             = var.domain_names

  origin {
    domain_name = var.origin_domain_name
    origin_id   = var.origin_id

    dynamic "custom_origin_config" {
      for_each = var.origin_type == "alb" ? [1] : []
      content {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }

    dynamic "s3_origin_config" {
      for_each = var.origin_type == "s3" ? [1] : []
      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.this[0].cloudfront_access_identity_path
      }
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = var.enable_https_only ? "redirect-to-https" : "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-cloudfront"
    }
  )
}

resource "aws_cloudfront_origin_access_identity" "this" {
  count   = var.origin_type == "s3" ? 1 : 0
  comment = "${var.environment} CloudFront Origin Access Identity"
}