/**
 * ## Usage
 *
 * Creates an IAM policy that explictly denies destructive actions.
 *
 * ```hcl
 * module "no_delete_policy" {
 *   source = "dod-iac/no-delete-policy/aws"
 * }
 * ```
 *
 * Creates a customized IAM policy that explictly denies certain destructive actions.
 *
 * ```hcl
 * module "no_delete_policy" {
 *   source = "dod-iac/no-delete-policy/aws"
 *
 *   buckets = []
 *   keys    = []
 *   name = "admin-no-delete"
 * }
 *
 * ```
 *
 * ## Testing
 *
 * Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use 'TT_VERBOSE=1' to log all tests as they are run.  The go test command can be executed directly, too.
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_iam_policy_document" "main" {

  #
  # IAM
  #

  dynamic "statement" {
    for_each = var.deny_iam_delete_users && length(var.iam_users) > 0 ? [true] : []
    content {
      sid = "DenyDeleteUsers"
      actions = [
        "iam:DeleteUser",
      ]
      effect    = "Deny"
      resources = var.iam_users
    }
  }

  #
  # S3
  #

  dynamic "statement" {
    for_each = var.deny_s3_delete_bucket && length(var.s3_buckets) > 0 ? [true] : []
    content {
      sid = "DenyDeleteBucket"
      actions = [
        "s3:DeleteBucket"
      ]
      effect    = "Deny"
      resources = var.s3_buckets
    }
  }

  dynamic "statement" {
    for_each = var.deny_s3_delete_bucket_policy && length(var.s3_buckets) > 0 ? [true] : []
    content {
      sid = "DenyDeleteBucketPolicy"
      actions = [
        "s3:DeleteBucketPolicy"
      ]
      effect    = "Deny"
      resources = var.s3_buckets
    }
  }

  dynamic "statement" {
    for_each = var.deny_s3_delete_object && length(var.s3_buckets) > 0 ? [true] : []
    content {
      sid = "DenyDeleteObject"
      actions = [
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ]
      effect    = "Deny"
      resources = length(var.s3_buckets) == 1 && var.s3_buckets[0] == "*" ? var.s3_buckets : formatlist("%s/*", var.s3_buckets)
    }
  }

  #
  # KMS
  #

  dynamic "statement" {
    for_each = var.deny_kms_delete_key && length(var.kms_keys) > 0 ? [true] : []
    content {
      sid = "DenyDeleteKey"
      actions = [
        "kms:ScheduleKeyDeletion",
        "kms:DeleteAlias",
        "kms:DeleteCustomKeyStore",
        "kms:DeleteImportedKeyMaterial",
        "kms:DisconnectCustomKeyStore"
      ]
      effect    = "Deny"
      resources = var.kms_keys
    }
  }

  dynamic "statement" {
    for_each = var.deny_kms_disable_key && length(var.kms_keys) > 0 ? [true] : []
    content {
      sid = "DenyDisableKey"
      actions = [
        "kms:DisableKey",
        "kms:DisableKeyRotation"
      ]
      effect    = "Deny"
      resources = var.kms_keys
    }
  }

}

resource "aws_iam_policy" "main" {
  name        = var.name
  description = length(var.description) > 0 ? var.description : format("The policy for %s.", var.name)
  policy      = data.aws_iam_policy_document.main.json
}
