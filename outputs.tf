output "aws_s3" {
  description = "Attributes from aws_s3_bucket (https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)"
  value       = aws_s3_bucket.bucket
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "aws_cloudfront" {
  description = "Attributes from aws_cloudfront_distribution (https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html)"
  value       = aws_cloudfront_distribution.dist
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution (use for cache invalidations)"
  value       = aws_cloudfront_distribution.dist.id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.dist.domain_name
}

output "aws_acm" {
  description = "Attributes from aws_acm_certificate (https://www.terraform.io/docs/providers/aws/r/acm_certificate.html)"
  value       = aws_acm_certificate.cert
  sensitive   = true
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.cert.arn
}

output "route53_validation_record" {
  description = "Route53 ACM validation record (when using Route53)"
  value       = var.use_route53 ? aws_route53_record.acm_validation[0] : null
}

output "route53_main_record" {
  description = "Route53 main domain record (when using Route53)"
  value       = var.use_route53 ? aws_route53_record.main[0] : null
}

output "cloudflare_acm_record" {
  description = "Cloudflare ACM validation record (when using Cloudflare)"
  value       = var.use_cloudflare ? cloudflare_record.acm[0] : null
}

output "cloudflare_main_record" {
  description = "Cloudflare main domain record (when using Cloudflare)"
  value       = var.use_cloudflare ? cloudflare_record.cname[0] : null
}
