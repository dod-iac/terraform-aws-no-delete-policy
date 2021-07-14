<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates an IAM policy that explictly denies destructive actions.

```hcl
module "no_delete_policy" {
  source = "dod-iac/no-delete-policy/aws"
}
```

Creates a customized IAM policy that explictly denies certain destructive actions.

```hcl
module "no_delete_policy" {
  source = "dod-iac/no-delete-policy/aws"

  buckets = []
  keys    = []
  name = "admin-no-delete"
}

```

## Testing

Run all terratest tests using the `terratest` script.  If using `aws-vault`, you could use `aws-vault exec $AWS_PROFILE -- terratest`.  The `AWS_DEFAULT_REGION` environment variable is required by the tests.  Use `TT_SKIP_DESTROY=1` to not destroy the infrastructure created during the tests.  Use 'TT\_VERBOSE=1' to log all tests as they are run.  The go test command can be executed directly, too.

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deny_iam_delete_users"></a> [deny\_iam\_delete\_users](#input\_deny\_iam\_delete\_users) | Deny deleting of the specified IAM users. | `bool` | `true` | no |
| <a name="input_deny_kms_delete_key"></a> [deny\_kms\_delete\_key](#input\_deny\_kms\_delete\_key) | Deny deleting of the specified KMS keys. | `bool` | `true` | no |
| <a name="input_deny_kms_disable_key"></a> [deny\_kms\_disable\_key](#input\_deny\_kms\_disable\_key) | Deny disabling of the specified KMS keys. | `bool` | `true` | no |
| <a name="input_deny_s3_delete_bucket"></a> [deny\_s3\_delete\_bucket](#input\_deny\_s3\_delete\_bucket) | Deny deleting of the specified AWS S3 buckets. | `bool` | `true` | no |
| <a name="input_deny_s3_delete_bucket_policy"></a> [deny\_s3\_delete\_bucket\_policy](#input\_deny\_s3\_delete\_bucket\_policy) | Deny deleting of the bucket policies for the specified AWS S3 buckets. | `bool` | `true` | no |
| <a name="input_deny_s3_delete_object"></a> [deny\_s3\_delete\_object](#input\_deny\_s3\_delete\_object) | Deny deleting of objects in the specified AWS S3 buckets. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the AWS IAM policy.  Defaults to "The policy for [NAME]." | `string` | `""` | no |
| <a name="input_iam_users"></a> [iam\_users](#input\_iam\_users) | The ARNs of the AWS IAM users.  Use ["*"] to apply policy to all users. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_kms_keys"></a> [kms\_keys](#input\_kms\_keys) | The ARNs of the AWS KMS keys.  Use ["*"] to apply policy to all keys. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the AWS IAM policy. | `string` | `"no-delete"` | no |
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | The ARNs of the AWS S3 buckets.  Use ["*"] to apply policy to all buckets. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the AWS IAM policy. |
| <a name="output_id"></a> [id](#output\_id) | The id of the AWS IAM policy. |
| <a name="output_name"></a> [name](#output\_name) | The name of the AWS IAM policy. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
