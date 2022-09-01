terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.28"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "mco" {
  bucket = "operate-first-multi-cluster-observability-thanos"
}

resource "aws_s3_bucket_acl" "mco" {
  bucket = aws_s3_bucket.mco.id
  acl    = "private"
}

resource "aws_iam_user" "mco" {
  name = "operate-first-multi-cluster-observability"
}

resource "aws_iam_access_key" "mco" {
  user = aws_iam_user.mco.name
}

resource "aws_iam_user_policy" "mco-rw" {
  name = "operate-first-multi-cluster-observability-bucket-rw"
  user = aws_iam_user.mco.name

  policy = <<EOF
{

    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowBucketOnly",
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::operate-first-multi-cluster-observability-thanos",
                "arn:aws:s3:::operate-first-multi-cluster-observability-thanos/*"
            ]
        }
    ]
}
EOF
}

output "bucket" {
  value = aws_s3_bucket.mco.bucket
}

output "access_key" {
  value     = aws_iam_access_key.mco.id
  sensitive = true
}

output "secret_key" {
  value     = aws_iam_access_key.mco.secret
  sensitive = true
}
