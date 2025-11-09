locals {
  # Common tags to apply to all resources
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "terraform-aws-static-websites"
    }
  )

  # S3 bucket name (same as domain name)
  bucket_name = var.domain_name

  # CloudFront origin ID
  origin_id = "s3-${var.domain_name}"

  # Determine which DNS provider is in use
  using_cloudflare = var.use_cloudflare
  using_route53    = var.use_route53
}

