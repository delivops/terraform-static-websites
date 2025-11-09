provider "aws" {
  region = var.aws_region
}

# Required for cloudfront certificate to be stored in us-east-1
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
provider "cloudflare" {
  # Fallback token needed because Cloudflare provider requires a token even when not creating resources
  api_token = var.cloudflare_api_token != "" ? var.cloudflare_api_token : "dummytokenusedforroute53onlydeployments"
}
