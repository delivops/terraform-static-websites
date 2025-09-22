output "aws_s3" {
  description = "Attributes from aws_s3_bucket (https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)"
  value       = aws_s3_bucket.bucket
}

output "aws_cloudfront" {
  description = "Attributes from aws_cloudfront_distribution (https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html)"
  value       = aws_cloudfront_distribution.dist
}

output "aws_acm" {
  description = "Attributes from aws_acm_certificate (https://www.terraform.io/docs/providers/aws/r/acm_certificate.html)"
  value       = aws_acm_certificate.cert
  sensitive   = true
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
