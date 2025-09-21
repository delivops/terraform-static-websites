variable "aws_region" {
  type        = string
  description = "The AWS region to put the bucket into"
}

variable "cloudflare_api_token" {
  type        = string
  description = "The Cloudflare API token for accessing Cloudfare"
}

variable "tags" {
  description = "Tags you would like to apply across AWS resources."
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "This is the domain name you want to use to point your website. (eg. example.com, www.example.com etc)"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The DNS zone ID in which add the record. You can get this from the domain view in the cloudflare dashboard."
  type        = string
  default     = ""
}

variable "logging_bucket" {
  description = "Logging Bucket"
  type        = string
  default     = ""
}

variable "use_route53" {
  description = "Whether to use Route53 for DNS records instead of Cloudflare"
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "The Route53 hosted zone ID where DNS records will be created (required if use_route53 is true)"
  type        = string
  default     = ""
  
  validation {
    condition     = !var.use_route53 || var.route53_zone_id != ""
    error_message = "route53_zone_id is required when use_route53 is true."
  }
}

variable "use_cloudflare" {
  description = "Whether to use Cloudflare for DNS records (defaults to true for backward compatibility)"
  type        = bool
  default     = true
}
