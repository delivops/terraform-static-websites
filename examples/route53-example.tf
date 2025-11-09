# Example using Route53 for DNS management
module "static_website_route53" {
  source = "../"

  domain_name = "example.com"
  aws_region  = var.aws_region

  # Route53 configuration
  use_route53     = true
  use_cloudflare  = false
  route53_zone_id = var.route53_zone_id

  # Cloudflare not needed when using Route53
  cloudflare_api_token = ""
  cloudflare_zone_id   = ""

  tags = {
    Environment = "prod"
    Terraform   = "true"
    DNS         = "route53"
  }
}