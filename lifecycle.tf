# Optional S3 Lifecycle Management
# Automatically enabled when version_retention_days > 0

# S3 Lifecycle configuration for version management
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  count = var.version_retention_days > 0 ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  # Remove old noncurrent versions after retention period
  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.version_retention_days
    }
  }

  # Clean up expired delete markers
  rule {
    id     = "clean-up-expired-delete-markers"
    status = "Enabled"

    expiration {
      expired_object_delete_marker = true
    }
  }

  # Abort incomplete multipart uploads after 7 days
  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

