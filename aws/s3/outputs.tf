output "bucket_id" {
  value       = aws_s3_bucket.tul-ccs.id
  description = "The ID of the File Storage bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.tul-ccs.arn
  description = "The ARN of the File Storage bucket"
}
