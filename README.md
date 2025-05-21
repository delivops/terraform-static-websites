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
