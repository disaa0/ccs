resource "aws_s3_bucket" "tul-ccs" {
  bucket = "tul-ccs"
}

resource "aws_s3_bucket_public_access_block" "tul-ccs" {
  bucket = aws_s3_bucket.tul-ccs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tul-ccs" {
  bucket = aws_s3_bucket.tul-ccs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "tul-ccs" {
  bucket = aws_s3_bucket.tul-ccs.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:*",
        "Resource": [
          "${aws_s3_bucket.tul-ccs.arn}",
          "${aws_s3_bucket.tul-ccs.arn}/*"
        ],
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"  # Enforce HTTPS
          }
        }
      }
    ]
  })
}

