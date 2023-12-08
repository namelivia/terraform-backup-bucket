output "access_key" {
  value = aws_iam_access_key.s3_user_access_key.id
}

output "secret_key" {
  value = aws_iam_access_key.s3_user_access_key.secret
}

output "bucket_url" {
  value = aws_s3_bucket.restic_backup.bucket_domain_name
}
