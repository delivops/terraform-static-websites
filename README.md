![image info](logo.jpeg)

# Static Website Hosting with S3, CloudFront, and ACM

This Terraform module sets up a static website hosted on AWS S3 and served through CloudFront with HTTPS using ACM, with DNS managed via Cloudflare.

## Features

- S3 bucket for hosting static website content
- CloudFront distribution for global delivery and HTTPS support
- ACM certificate for SSL (via DNS validation)
- Cloudflare DNS configuration for domain pointing
- Versioning enabled for S3 bucket
- Bucket policy restricts access to CloudFront only

## Resources Created

- AWS S3 bucket (with website hosting configuration)
- AWS ACM certificate (validated via Cloudflare DNS)
- AWS CloudFront distribution
- Cloudflare DNS records (ACM validation + CNAME to CloudFront)
- IAM policy document for bucket access
- S3 versioning and ownership controls

## Usage

Ensure your `index.html` file is placed inside the S3 bucket after deployment to enable the website to load correctly.

```hcl
module "static_website" {
  source = "./path-to-this-module"

  domain_name        = "yourdomain.com"
  tags               = {
    Environment = "production"
    Project     = "static-site"
  }
  cloudflare_zone_id = "your-cloudflare-zone-id"
  logging_bucket      = "your-logging-bucket-name" // optional, set empty string to disable
}
```

## Notes

- The S3 bucket is private and only accessible through the CloudFront distribution.
- Make sure to have Cloudflare API access configured for Terraform.
- The ACM certificate is provisioned in the `us-east-1` region, as required by CloudFront.
- You **must** upload an `index.html` to the S3 bucket after deploying the infrastructure.

## License

This module is released under the MIT License.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.67.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.67.0 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | >= 4.67.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.dist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.bucket_ownership_controls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_versioning.bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.bucket_website_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [cloudflare_record.acm](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.cname](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [aws_iam_policy_document.bucket_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to put the bucket into | `string` | n/a | yes |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | The Cloudflare API token for accessing Cloudfare | `string` | n/a | yes |
| <a name="input_cloudflare_zone_id"></a> [cloudflare\_zone\_id](#input\_cloudflare\_zone\_id) | The DNS zone ID in which add the record. You can get this from the domain view in the cloudflare dashboard. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | This is the domain name you want to use to point your website. (eg. example.com, www.example.com etc) | `string` | n/a | yes |
| <a name="input_logging_bucket"></a> [logging\_bucket](#input\_logging\_bucket) | Logging Bucket | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags you would like to apply across AWS resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_acm"></a> [aws\_acm](#output\_aws\_acm) | Attributes from aws\_acm\_certificate (https://www.terraform.io/docs/providers/aws/r/acm_certificate.html) |
| <a name="output_aws_cloudfront"></a> [aws\_cloudfront](#output\_aws\_cloudfront) | Attributes from aws\_cloudfront\_distribution (https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html) |
| <a name="output_aws_s3"></a> [aws\_s3](#output\_aws\_s3) | Attributes from aws\_s3\_bucket (https://www.terraform.io/docs/providers/aws/r/s3_bucket.html) |
<!-- END_TF_DOCS -->