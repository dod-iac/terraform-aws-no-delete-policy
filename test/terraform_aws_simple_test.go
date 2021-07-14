// =================================================================
//
// Work of the U.S. Department of Defense, Defense Digital Service.
// Released as open source under the MIT License.  See LICENSE file.
//
// =================================================================

package test

import (
	"bytes"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/aws/credentials/stscreds"
	"github.com/aws/aws-sdk-go/service/s3"
)

var (
	testObjectKey = "test.txt"
)

func cleanup(s *session.Session, region string, testName string, testBucketName string, objectVersionID string) {
	s3Client := s3.New(s, aws.NewConfig().WithRegion(region))
	// Delete test object
	_, _ = s3Client.DeleteObject(&s3.DeleteObjectInput{
		Bucket: aws.String(testBucketName),
		Key: aws.String(testObjectKey),
		VersionId: aws.String(objectVersionID),
	})
}

func TestTerraformSimpleExample(t *testing.T) {

	// Allow test to run in parallel with other tests
	t.Parallel()

	region := os.Getenv("AWS_DEFAULT_REGION")

	// If AWS_DEFAULT_REGION environment variable is not set, then fail the test.
	require.NotEmpty(t, region, "missing environment variable AWS_DEFAULT_REGION")

	// Append a random suffix to the test name, so individual test runs are unique.
	// When the test runs again, it will use the existing terraform state,
	// so it should override the existing infrastructure.
	testName := fmt.Sprintf("terratest-no-delete-policy-simple-%s", strings.ToLower(random.UniqueId()))

	tags := map[string]interface{}{
		"Automation": "Terraform",
		"Terratest":  "yes",
		"Test":       "TestTerraformSimpleExample",
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// TerraformDir is where the terraform state is found.
		TerraformDir: "../examples/simple",
		// Set the variables passed to terraform
		Vars: map[string]interface{}{
			"test_name": testName,
			"tags": tags,
		},
		// Set the environment variables passed to terraform.
		// AWS_DEFAULT_REGION is the only environment variable strictly required,
		// when using the AWS provider.
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
	})

	// If TT_SKIP_DESTROY is set to "1" then do not destroy the intrastructure,
	// at the end of the test run
	if os.Getenv("TT_SKIP_DESTROY") != "1" {
		defer terraform.Destroy(t, terraformOptions)
	}

	// InitAndApply runs "terraform init" and then "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	testBucketName := terraform.Output(t, terraformOptions, "test_bucket_name")

	testRoleARN := terraform.Output(t, terraformOptions, "test_role_arn")

  // Assume the test role
	s := session.Must(session.NewSession())

	originalS3Client := s3.New(s, aws.NewConfig().WithRegion(region))

	newCredentials := stscreds.NewCredentials(s, testRoleARN)

	newS3Client := s3.New(s, &aws.Config{
		CredentialsChainVerboseErrors: aws.Bool(true),
		Credentials: newCredentials,
		Region: aws.String(region),
	})

	getBucketPolicyOutput, getBucketPolicyError := newS3Client.GetBucketPolicy(&s3.GetBucketPolicyInput{
		Bucket: aws.String(testBucketName),
	})

	// Check that role has S3 permissions
	require.NoError(t, getBucketPolicyError)

	t.Log(aws.StringValue(getBucketPolicyOutput.Policy))

	listObjectsOutput, listObjectsError := newS3Client.ListObjects(&s3.ListObjectsInput{
		Bucket: aws.String(testBucketName),
	})

	// Check that role has S3 permissions
	require.NoError(t, listObjectsError, fmt.Sprintf("Could not list bucket %q", testBucketName))

	for _, obj := range listObjectsOutput.Contents {
		t.Logf("%s:%s", aws.TimeValue(obj.LastModified), aws.StringValue(obj.Key))
	}

	// Attempt to put an object into the test bucket
	putObjectOutput, putObjectError := newS3Client.PutObject(&s3.PutObjectInput{
		ACL: aws.String("bucket-owner-full-control"),
		Bucket: aws.String(testBucketName),
		Body: aws.ReadSeekCloser(bytes.NewReader([]byte("test"))),
		Key: aws.String(testObjectKey),
		ServerSideEncryption: aws.String("AES256"),
	})

	// Check that no error occured
	require.NoError(t, putObjectError)

  // Defer cleanup of resources
	defer cleanup(s, region, testName, testBucketName, aws.StringValue(putObjectOutput.VersionId))

	// Attempt to delete the object using IAM role
	_, deleteObjectError := newS3Client.DeleteObject(&s3.DeleteObjectInput{
		Bucket: aws.String(testBucketName),
		Key: aws.String(testObjectKey),
		VersionId: putObjectOutput.VersionId,
	})

	// Check that an error occured
	require.Error(t, deleteObjectError)

	// Check that the expected error occured
	deleteObjectAWSError, deleteObjectAWSErrorOK := deleteObjectError.(awserr.Error)
	if ! deleteObjectAWSErrorOK {
		require.FailNow(t, fmt.Sprintf("unexpected error when deleting bucket: %s", deleteObjectError.Error()))
	}

	// Check why the request to delete the object was denied
	require.Equal(t, "Access Denied", deleteObjectAWSError.Message())

  // Delete object using original credentials
	_, _ = originalS3Client.DeleteObject(&s3.DeleteObjectInput{
		Bucket: aws.String(testBucketName),
		Key: aws.String(testObjectKey),
		VersionId: putObjectOutput.VersionId,
	})

  // Attempt to delete the bucket
	_, deleteBucketError := newS3Client.DeleteBucket(&s3.DeleteBucketInput{
		Bucket: aws.String(testBucketName),
	})

	// Check that an error occured
	require.Error(t, deleteBucketError)

	// Check that the expected error occured
	deleteBucketAWSError, deleteBucketAWSErrorOK := deleteBucketError.(awserr.Error)
	if ! deleteBucketAWSErrorOK {
		require.FailNow(t, fmt.Sprintf("unexpected error when deleting bucket: %s", deleteBucketError.Error()))
	}

	// Check why the request to delete the bucket was denied
	require.Equal(t, "Access Denied", deleteBucketAWSError.Message())
}
