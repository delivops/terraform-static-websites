variable "aws_region" {
  type        = string
  description = "The AWS region to put the bucket into"
  
}
variable "cloudflare_api_token" {
  type        = string
  description = "The Cloudflare API token for accessing Cloudfare"
  
}

variable "cloudflare_zone_id" {
  description = "The DNS zone ID in which add the record. You can get this from the domain view in the cloudflare dashboard."
  type        = string
  
}

variable "route53_zone_id" {
  description = "The Route53 hosted zone ID where DNS records will be created (required when using Route53)"
  type        = string
  default     = ""
}