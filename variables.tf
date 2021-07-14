#
# IAM Actions
#

variable "deny_iam_delete_users" {
  type        = bool
  description = "Deny deleting of the specified IAM users."
  default     = true
}

variable "iam_users" {
  type        = list(string)
  description = "The ARNs of the AWS IAM users.  Use [\"*\"] to apply policy to all users."
  default     = ["*"]
}

#
# KMS Actions
#

variable "deny_kms_delete_key" {
  type        = bool
  description = "Deny deleting of the specified KMS keys."
  default     = true
}

variable "deny_kms_disable_key" {
  type        = bool
  description = "Deny disabling of the specified KMS keys."
  default     = true
}

variable "kms_keys" {
  type        = list(string)
  description = "The ARNs of the AWS KMS keys.  Use [\"*\"] to apply policy to all keys."
  default     = ["*"]
}

#
# S3 Actions
#

variable "deny_s3_delete_bucket" {
  type        = bool
  description = "Deny deleting of the specified AWS S3 buckets."
  default     = true
}

variable "deny_s3_delete_bucket_policy" {
  type        = bool
  description = "Deny deleting of the bucket policies for the specified AWS S3 buckets."
  default     = true
}

variable "deny_s3_delete_object" {
  type        = bool
  description = "Deny deleting of objects in the specified AWS S3 buckets."
  default     = true
}

variable "s3_buckets" {
  type        = list(string)
  description = "The ARNs of the AWS S3 buckets.  Use [\"*\"] to apply policy to all buckets."
  default     = ["*"]
}

#
# Policy Variables
#

variable "description" {
  type        = string
  description = "The description of the AWS IAM policy.  Defaults to \"The policy for [NAME].\""
  default     = ""
}

variable "name" {
  type        = string
  description = "The name of the AWS IAM policy."
  default     = "no-delete"
}
