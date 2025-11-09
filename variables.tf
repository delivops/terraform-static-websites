variable "aws_region" {
  type        = string
  description = "The AWS region to put the bucket into"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "The aws_region must be a valid AWS region format (e.g., us-east-1, eu-west-2)."
  }
}

variable "cloudflare_api_token" {
  type        = string
  description = "The Cloudflare API token for accessing Cloudfare (only required when use_cloudflare = true)"
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "Tags you would like to apply across AWS resources."
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "This is the domain name you want to use to point your website. (eg. example.com, www.example.com etc)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]\\.[a-z]{2,}$", var.domain_name))
    error_message = "The domain_name must be a valid domain format (e.g., example.com, sub.example.com)."
  }
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

  validation {
    condition     = var.logging_bucket == "" || can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.logging_bucket))
    error_message = "The logging_bucket must be a valid S3 bucket name or empty string."
  }
}

variable "use_route53" {
  description = "Whether to use Route53 for DNS records"
  type        = bool
  default     = true
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
  description = "Whether to use Cloudflare for DNS records"
  type        = bool
  default     = false

  validation {
    condition     = !(var.use_cloudflare && var.use_route53)
    error_message = "Cannot enable both use_cloudflare and use_route53. Please choose only one DNS provider."
  }
}

variable "error_responses" {
  description = "Map of error codes to error page paths. Supports custom error handling for different HTTP status codes."
  type = map(object({
    response_page_path = string
    response_code      = number
  }))
  default = {
    "403" = {
      response_page_path = "/index.html"
      response_code      = 200
    }
    "404" = {
      response_page_path = "/index.html"
      response_code      = 200
    }
  }
}

variable "version_retention_days" {
  description = "Number of days to keep old object versions. Set to 0 to disable lifecycle rules."
  type        = number
  default     = 90
}
