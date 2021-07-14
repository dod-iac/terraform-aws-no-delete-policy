output "iam_policy_arn" {
  value = module.iam_policy.arn
}

output "iam_policy_id" {
  value = module.iam_policy.id
}

output "iam_policy_name" {
  value = module.iam_policy.name
}

output "test_bucket_name" {
  value = aws_s3_bucket.test.id
}

output "test_role_arn" {
  value = aws_iam_role.test.arn
}

output "test_kms_key_arn" {
  value = aws_kms_key.test.arn
}

output "test_kms_key_alias_arn" {
  value = aws_kms_alias.test.arn
}
