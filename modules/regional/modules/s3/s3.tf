data "aws_caller_identity" "current" {}

##########################################
# S3 Bucket
##########################################
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.environment_name}-flowlogs-bucket"

}

##########################################
# S3 Bucket Policy
##########################################
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = data.aws_iam_policy_document.s3_policy.json
}


##################################
# Policy for S3
##################################
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "AWSLogDeliveryWrite"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.log_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = ["${aws_s3_bucket.log_bucket.arn}"]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
  statement {
    sid = "AllowSSLRequestsOnly"
    actions = [
      "s3:*"
    ]
    effect    = "Deny"
    resources = ["${aws_s3_bucket.log_bucket.arn}", "${aws_s3_bucket.log_bucket.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }
}