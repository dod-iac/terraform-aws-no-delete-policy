// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "iam_policy" {
  source = "../../"
}

#
# The following resources are used for testing.
#

resource "aws_kms_key" "test" {
  description             = format("Test KMS key for %s", var.test_name)
  deletion_window_in_days = 7
  enable_key_rotation     = "true"
  tags                    = var.tags
}

resource "aws_kms_alias" "test" {
  name          = format("alias/%s", var.test_name)
  target_key_id = aws_kms_key.test.key_id
}

resource "aws_s3_bucket" "test" {
  bucket = var.test_name
  tags   = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "test" {
  bucket = aws_s3_bucket.test.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}


data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "test" {
  name               = format("test-role-%s", var.test_name)
  description        = format("Test role for %s", var.test_name)
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "test_role_policy" {
  statement {
    sid = "AllowGetBucketLocation"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    effect = "Allow"
    resources = ["*"]
  }
  /*statement {
    sid = "AllowGetBucketLocation"
    actions = [
      "s3:*",
    ]
    effect    = "Allow"
    resources = ["*"]
  }*/
  # AllowS3
  statement {
    sid = "AllowS3"
    actions = [
      "s3:*"
    ]
    effect = "Allow"
    resources = [
      aws_s3_bucket.test.arn,
      format("%s/*", aws_s3_bucket.test.arn)
    ]
  }
}

resource "aws_iam_policy" "test_policy_allow" {
  name        = format("%s-allow-s3", var.test_name)
  description = format("The policy for the test role for %s.", var.test_name)
  policy      = data.aws_iam_policy_document.test_role_policy.json
}

resource "aws_iam_role_policy_attachment" "test_policy_attachment" {
  role       = aws_iam_role.test.name
  policy_arn = module.iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "test_policy_allow_attachment" {
  role       = aws_iam_role.test.name
  policy_arn = aws_iam_policy.test_policy_allow.arn
}
