provider "aws" {
  region = var.aws_region
}

# Required for cloudfront certificate to be stored in us-east-1
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
provider "cloudflare" {
  api_token = var.cloudflare_api_token != "" ? var.cloudflare_api_token : "1234567890abcdef1234567890abcdef12345678"
}
