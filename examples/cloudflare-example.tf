# Example using Cloudflare for DNS management (default behavior)
module "funnel_3_static_website" {
  source      = "../"
  domain_name = "games.internal.delivops.com"
  aws_region  = var.aws_region

  # Cloudflare configuration (default)
  use_cloudflare       = true
  use_route53          = false
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id

  # Route53 not used in this example
  route53_zone_id = ""

  tags = {
    Environment = "prod"
    Terraform   = "true"
    DNS         = "cloudflare"
  }
}
