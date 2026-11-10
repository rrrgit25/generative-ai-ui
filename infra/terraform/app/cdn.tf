# One CloudFront distribution serves everything over HTTPS on a single origin, which avoids
# mixed-content and most CORS issues:
#   /api/*, /media/*, /actuator/health*  -> k3s node (Traefik ingress -> Spring Boot)
#   everything else                      -> S3 (React SPA)

data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}

data "aws_cloudfront_response_headers_policy" "security" {
  name = "Managed-SecurityHeadersPolicy"
}

resource "aws_cloudfront_origin_access_control" "frontend" {
  count                             = local.cf
  name                              = "${local.name}-frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Client-side routing: rewrite extension-less paths to /index.html (only on the S3 behavior, so
# API 404s stay real 404s).
resource "aws_cloudfront_function" "spa_rewrite" {
  count   = local.cf
  name    = "${local.name}-spa-rewrite"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-JS
    function handler(event) {
      var req = event.request;
      if (!req.uri.includes('.')) { req.uri = '/index.html'; }
      return req;
    }
  JS
}

locals {
  s3_origin_id  = "s3-frontend"
  api_origin_id = "k3s-backend"
  api_paths     = ["/api/*", "/actuator/health*"]
}

resource "aws_cloudfront_distribution" "main" {
  count               = local.cf
  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.name
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  http_version        = "http2and3"

  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend[0].id
  }

  origin {
    origin_id   = local.api_origin_id
    domain_name = aws_eip.node.public_dns

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 60 # image/video generation can be slow (60s is the default max)
      origin_keepalive_timeout = 5
    }
  }

  default_cache_behavior {
    target_origin_id           = local.s3_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.spa_rewrite[0].arn
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.api_paths
    content {
      path_pattern               = ordered_cache_behavior.value
      target_origin_id           = local.api_origin_id
      viewer_protocol_policy     = "https-only"
      allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods             = ["GET", "HEAD"]
      compress                   = true
      cache_policy_id            = data.aws_cloudfront_cache_policy.disabled.id
      origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
      response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security.id
    }
  }

  # Generated media has random UUID filenames, so it is safe to cache at the edge.
  ordered_cache_behavior {
    path_pattern               = "/media/*"
    target_origin_id           = local.api_origin_id
    viewer_protocol_policy     = "https-only"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security.id
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
