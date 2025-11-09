[![DelivOps banner](https://raw.githubusercontent.com/delivops/.github/main/images/banner.png?raw=true)](https://delivops.com)

# Static Website Hosting with S3, CloudFront, and ACM

This Terraform module sets up a static website hosted on AWS S3 and served through CloudFront with HTTPS using ACM, with DNS managed via either Cloudflare or Route53.

## Features

### Core Features
- S3 bucket for hosting static website content (bucket name = domain name)
- CloudFront distribution with modern cache policies for global delivery and HTTPS support
- ACM certificate for SSL (via DNS validation)
- DNS configuration via Cloudflare or Route53
- S3 versioning enabled for data protection
- Bucket policy restricts access to CloudFront only
- Automatic compression (gzip, brotli) enabled
- SPA support (403/404 errors redirect to index.html by default)

### Optional Production Features (Auto-Enable)
- **Lifecycle Management**: Automatic cleanup of old S3 versions (enabled by default, 90-day retention)
- **Custom Error Pages**: Configurable error responses for any HTTP status code
- **Enhanced Security**: Input validation, sensitive variable protection

### Module Philosophy

This module is **opinionated** for simplicity:
- Lifecycle rules enabled by default (protects against storage costs)
- Bucket name always matches domain name
- No separate enable flags - features activate based on values

**Why these choices?** See [DESIGN_DECISIONS.md](DESIGN_DECISIONS.md) for the rationale behind our opinionated defaults.

## Resources Created

- AWS S3 bucket (with website hosting configuration)
- AWS ACM certificate (validated via DNS)
- AWS CloudFront distribution
- DNS records for ACM validation and domain pointing (via Cloudflare or Route53)
- IAM policy document for bucket access
- S3 versioning and ownership controls

## Usage

Ensure your `index.html` file is placed inside the S3 bucket after deployment to enable the website to load correctly.

### Using Route53 (Default)

```hcl
module "static_website" {
  source = "./path-to-this-module"

  domain_name     = "yourdomain.com"
  aws_region      = "us-east-1"
  
  # Route53 configuration (default)
  route53_zone_id = "Z1D633PJN98FT9"
  
  tags = {
    Environment = "production"
    Project     = "static-site"
  }
}
```

See [examples/route53/](examples/route53/) for complete example.

### Using Cloudflare

```hcl
module "static_website" {
  source = "./path-to-this-module"

  domain_name          = "yourdomain.com"
  aws_region           = "us-east-1"
  
  # Cloudflare configuration
  use_cloudflare       = true
  use_route53          = false
  cloudflare_api_token = "your-cloudflare-api-token"
  cloudflare_zone_id   = "your-cloudflare-zone-id"
  
  tags = {
    Environment = "production"
    Project     = "static-site"
  }
}
```

See [examples/cloudflare/](examples/cloudflare/) for complete example.

## DNS Provider Selection

- **Route53**: Default behavior (`use_route53 = true`, `use_cloudflare = false`)
- **Cloudflare**: Set `use_cloudflare = true` and `use_route53 = false`
- You can enable both, but typically you'd only use one DNS provider per deployment

## Optional Features

### Lifecycle Management

S3 lifecycle rules are automatically enabled when `version_retention_days > 0` (default is 90 days):

```hcl
module "static_website" {
  source = "./path-to-this-module"
  
  # ... other variables ...
  
  # Lifecycle rules enabled by default (90 days retention)
  version_retention_days = 90  # Set to 0 to disable
  
  # Old versions are automatically deleted after 90 days
  # Expired delete markers are cleaned up
  # Incomplete multipart uploads are aborted after 7 days
}
```

### Custom Error Pages

Configure custom error responses for different HTTP status codes:

```hcl
module "static_website" {
  source = "./path-to-this-module"
  
  # ... other variables ...
  
  error_responses = {
    "404" = {
      response_page_path = "/404.html"
      response_code      = 404
    }
    "500" = {
      response_page_path = "/error.html"
      response_code      = 500
    }
  }
}
```

## Cache Invalidation

After updating your website content, invalidate the CloudFront cache:

```bash
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"
```

## Security Considerations

- **Sensitive Variables**: The `cloudflare_api_token` is marked as sensitive and won't appear in logs
- **S3 Bucket**: Private by default, accessible only through CloudFront
- **HTTPS Only**: All traffic redirected to HTTPS
- **Input Validation**: Domain names, regions, and other inputs are validated

For more details, see [SECURITY.md](SECURITY.md).

## Troubleshooting

### 403 Forbidden Errors
- Verify that `index.html` exists in your S3 bucket
- Check CloudFront Origin Access Identity configuration
- Ensure S3 bucket policy allows CloudFront access

### Certificate Validation Stuck
- Verify DNS records are correctly created
- For Cloudflare: Check API token permissions
- For Route53: Verify hosted zone ID is correct
- DNS propagation can take 5-30 minutes

### High 4xx/5xx Error Rates
- Check CloudWatch Logs if logging is enabled
- Verify all required files exist in S3
- Review CloudFront metrics in AWS Console

### Terraform State Issues
- Always use remote state (S3 + DynamoDB) for production
- Enable state encryption
- Use state locking to prevent concurrent modifications

## Upgrading from v1.x to v2.x

Version 2.0 includes important updates:

1. **Terraform Version**: Now requires >= 1.3.0
2. **AWS Provider**: Now requires >= 5.0.0
3. **Cloudflare Provider**: Now requires ~> 4.0
4. **Cache Policy**: Migrated from deprecated `forwarded_values` to managed cache policies

### Migration Steps

```bash
# 1. Update provider versions in your configuration
# 2. Run terraform init -upgrade
terraform init -upgrade

# 3. Plan to see changes (should be minimal)
terraform plan

# 4. Apply changes
terraform apply
```

**Note**: The cache policy migration maintains the same caching behavior and should not require resource recreation.

See [CHANGELOG.md](CHANGELOG.md) for complete details.

## Notes

- The S3 bucket is private and only accessible through the CloudFront distribution.
- When using Cloudflare: Make sure to have Cloudflare API access configured for Terraform.
- When using Route53: The Route53 hosted zone must already exist for your domain.
- The ACM certificate is provisioned in the `us-east-1` region, as required by CloudFront.
- Route53 uses an A record with alias pointing to CloudFront, while Cloudflare uses a CNAME.
- You **must** upload an `index.html` to the S3 bucket after deploying the infrastructure.
- CloudFront cache policies provide better performance than the deprecated `forwarded_values`.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.0 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | 6.14.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 3.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.dist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_route53_record.acm_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
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
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | The Cloudflare API token for accessing Cloudfare (only required when use\_cloudflare = true) | `string` | `""` | no |
| <a name="input_cloudflare_zone_id"></a> [cloudflare\_zone\_id](#input\_cloudflare\_zone\_id) | The DNS zone ID in which add the record. You can get this from the domain view in the cloudflare dashboard. | `string` | `""` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | This is the domain name you want to use to point your website. (eg. example.com, www.example.com etc) | `string` | n/a | yes |
| <a name="input_logging_bucket"></a> [logging\_bucket](#input\_logging\_bucket) | Logging Bucket | `string` | `""` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | The Route53 hosted zone ID where DNS records will be created (required if use\_route53 is true) | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags you would like to apply across AWS resources. | `map(string)` | `{}` | no |
| <a name="input_use_cloudflare"></a> [use\_cloudflare](#input\_use\_cloudflare) | Whether to use Cloudflare for DNS records | `bool` | `false` | no |
| <a name="input_use_route53"></a> [use\_route53](#input\_use\_route53) | Whether to use Route53 for DNS records | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_acm"></a> [aws\_acm](#output\_aws\_acm) | Attributes from aws\_acm\_certificate (https://www.terraform.io/docs/providers/aws/r/acm_certificate.html) |
| <a name="output_aws_cloudfront"></a> [aws\_cloudfront](#output\_aws\_cloudfront) | Attributes from aws\_cloudfront\_distribution (https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html) |
| <a name="output_aws_s3"></a> [aws\_s3](#output\_aws\_s3) | Attributes from aws\_s3\_bucket (https://www.terraform.io/docs/providers/aws/r/s3_bucket.html) |
| <a name="output_cloudflare_acm_record"></a> [cloudflare\_acm\_record](#output\_cloudflare\_acm\_record) | Cloudflare ACM validation record (when using Cloudflare) |
| <a name="output_cloudflare_main_record"></a> [cloudflare\_main\_record](#output\_cloudflare\_main\_record) | Cloudflare main domain record (when using Cloudflare) |
| <a name="output_route53_main_record"></a> [route53\_main\_record](#output\_route53\_main\_record) | Route53 main domain record (when using Route53) |
| <a name="output_route53_validation_record"></a> [route53\_validation\_record](#output\_route53\_validation\_record) | Route53 ACM validation record (when using Route53) |
<!-- END_TF_DOCS -->