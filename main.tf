terraform {
  required_providers {
    aws = {
      version = ">= 4.67.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }

  }
}


