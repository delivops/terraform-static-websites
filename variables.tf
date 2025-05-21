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
}

variable "logging_bucket" {
  description = "Logging Bucket"
  type        = string
  default     = ""
}
