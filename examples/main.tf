module "funnel_3_static_website" {
  source               = "../"
  domain_name          = "games.internal.delivops.com"
  aws_region           = var.aws_region
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}
