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

data "aws_iam_policy_document" "s3_policy" {
  source_json = <<JSON
{
    "Version": "2012-10-17",
    "Id": "Policy${var.bucket_name}",
    "Statement": [{
      "Sid": "AllowAllS3Actions",
      "Principal": "*",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    }]
}
JSON
}

resource "aws_iam_policy" "s3_policy" {
  name        = "restic-backup-policy"
  description = "Policy for S3 bucket access"
  policy      = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_iam_user_policy_attachment" "attach_s3_policy" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role" "s3_role" {
  name = "${var.bucket_name}-role"
  assume_role_policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy_role" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}
