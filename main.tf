terraform {
  required_version = ">= 1.0.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_s3_bucket" "restic_backup" {
  bucket = "${var.bucket_name}"
  acl    = "private"
}

resource "aws_iam_user" "s3_user" {
  name = "${var.bucket_name}-user"
}

resource "aws_iam_access_key" "s3_user_access_key" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name   = "s3-user-policy"
  user   = aws_iam_user.s3_user.name

  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::{var.bucket_name}",
        "arn:aws:s3:::{var.bucket_name}/*"
      ]
    }
  ]
}
JSON
}
