resource "aws_s3_bucket" "logs" {
  bucket        = "chaos-engineering-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.bucket
  rule {
    id = "fis-logs"
    expiration {
      days = 7
    }
    status = "Enabled"
  }
}