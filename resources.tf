/* S3 bucket hosting the static website */
resource "aws_s3_bucket" "bucket" {
  bucket = var.domain_name
  tags   = var.tags
}

resource "aws_s3_bucket_website_configuration" "bucket_website_configuration" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket     = aws_s3_bucket.bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership_controls]
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json

}

/* ACM certificate */
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  provider          = aws.virginia
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

/* Cloudflare ACM validation record  */
resource "cloudflare_record" "acm" {
  count      = var.use_cloudflare ? 1 : 0
  depends_on = [aws_acm_certificate.cert]

  zone_id = var.cloudflare_zone_id
  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  value   = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
}

/* Route53 ACM validation record */
resource "aws_route53_record" "acm_validation" {
  count   = var.use_route53 ? 1 : 0
  depends_on = [aws_acm_certificate.cert]

  zone_id = var.route53_zone_id
  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  ttl     = 300
}

/* ACM Validation after adding DNS record */
resource "aws_acm_certificate_validation" "cert" {
  provider   = aws.virginia
  depends_on = [aws_acm_certificate.cert]

  certificate_arn = aws_acm_certificate.cert.arn
  
  validation_record_fqdns = var.use_route53 ? [
    aws_route53_record.acm_validation[0].fqdn
  ] : (var.use_cloudflare ? [
    cloudflare_record.acm[0].hostname
  ] : [])
}

/* Cloudfront distribution in front of S3 bucket */
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "s3-${var.domain_name}"
}

resource "aws_cloudfront_distribution" "dist" {
  depends_on = [aws_s3_bucket.bucket, aws_acm_certificate_validation.cert]

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "s3-${var.domain_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.domain_name]

  // add logging if required
  dynamic "logging_config" {
    for_each = var.logging_bucket != "" ? [1] : []
    content {
      include_cookies = false
      bucket          = var.logging_bucket
      prefix          = "cloudfront"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  custom_error_response {
    response_page_path = "/index.html"
    error_code         = 403
    response_code      = 200
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-${var.domain_name}"

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

    // https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
    // the id for "CORS-With-Preflight" response policy
    response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"


  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = var.tags
}

/* CNAME record to Cloudflare DNS points to the cloudfront distribution */
resource "cloudflare_record" "cname" {
  count      = var.use_cloudflare ? 1 : 0
  depends_on = [aws_cloudfront_distribution.dist]

  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  value   = aws_cloudfront_distribution.dist.domain_name
  type    = "CNAME"
}

/* Route53 record pointing to CloudFront distribution */
resource "aws_route53_record" "main" {
  count   = var.use_route53 ? 1 : 0
  depends_on = [aws_cloudfront_distribution.dist]

  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.dist.domain_name
    zone_id               = aws_cloudfront_distribution.dist.hosted_zone_id
    evaluate_target_health = false
  }
}
