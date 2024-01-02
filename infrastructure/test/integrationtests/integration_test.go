package test

import (
	"crypto/tls"
	"fmt"
	"io/ioutil"
	"math/rand"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	awsSDK "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func moveTerraformTestProviderLocalStack() {
	// Specify the source and destination directories
	sourceDir := ".."
	destinationDir := "../../code/environments/dev"
	// Specify the Terraform file name
	terraformFileName := "provider-test.tf"
	// Build the source and destination file paths
	sourceFilePath := filepath.Join(sourceDir, terraformFileName)
	destinationFilePath := filepath.Join(destinationDir, "provider.tf")

	// Check if the source file exists
	if _, err := os.Stat(sourceFilePath); os.IsNotExist(err) {
		fmt.Println("Source file does not exist:", sourceFilePath)
		return
	}
	// Create the destination directory if it doesn't exist
	if err := os.MkdirAll(destinationDir, 0755); err != nil {
		fmt.Println("Error creating destination directory:", err)
		return
	}
	// Read the content of the source file
	content, err := ioutil.ReadFile(sourceFilePath)
	if err != nil {
		fmt.Println("Error reading source file:", err)
		return
	}
	// Write the content to the destination file
	err = ioutil.WriteFile(destinationFilePath, content, 0644)
	if err != nil {
		fmt.Println("Error writing to destination file:", err)
		return
	}
	// Optionally, you can remove the source file after copying it
	// if err := os.Remove(sourceFilePath); err != nil {
	//  fmt.Println("Error removing source file:", err)
	//  return
	// }

	// Run "terraform init" in the specified directory
	cmd := exec.Command("terraform", "init", "-reconfigure")
	cmd.Dir = destinationDir

	// Capture and display the command output
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("Error running 'terraform init':", err)
		return
	}
	fmt.Println("Terraform init output:", string(output))

	fmt.Println("Terraform file moved and renamed successfully!")
}
func doesSecretExist(secretsManagerClient *secretsmanager.SecretsManager, secretName string) (bool, error) {
	describeSecretInput := &secretsmanager.DescribeSecretInput{
		SecretId: awsSDK.String(secretName),
	}

	_, err := secretsManagerClient.DescribeSecret(describeSecretInput)

	if err != nil {
		// If the error is because the secret doesn't exist, return false
		if _, ok := err.(*secretsmanager.ResourceNotFoundException); ok {
			return false, nil
		}
		return false, err
	}

	// Secret exists
	return true, nil
}
// An example of how to test the Terraform module in examples/terraform-aws-ecs-example using Terratest.
func TestTerraformAwsEcsExample(t *testing.T) {
	t.Parallel()
	randomNumber := rand.Intn(101)
	env_name := fmt.Sprintf("%s%d", "itest", randomNumber)
	expectedClusterName := env_name + "-new-blogdemo-cluster"
	expectedServiceName := env_name + "-existing-blogdemo-demoapp"

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := aws.GetRandomStableRegion(t, []string{"eu-north-1"}, nil)
	// Generate a random number between 0 and 100

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	moveTerraformTestProviderLocalStack()

	localEndpoint := "http://localhost:4566" // Change the port if LocalStack is running on a different port
	// Create a new session using the default AWS credentials and the us-west-2 region.
	sess := session.Must(session.NewSession(&awsSDK.Config{
		Endpoint:   awsSDK.String(localEndpoint),
		DisableSSL: awsSDK.Bool(true),           // Disable SSL for local development
		Region:     awsSDK.String("eu-north-1"), // Change this to your desired AWS region
	}))
	// Create an EC2 service client.
	svc := ec2.New(sess)
	// Specify the filter to find the default VPC.
	filters := []*ec2.Filter{
		{
			Name:   awsSDK.String("isDefault"),
			Values: []*string{awsSDK.String("true")},
		},
	}
	// Describe VPCs with the specified filter.
	result, err := svc.DescribeVpcs(&ec2.DescribeVpcsInput{
		Filters: filters,
	})
	if err != nil {
		fmt.Println("Error describing VPCs:", err)
		return
	}
	// Check if there is at least one default VPC.
	if len(result.Vpcs) == 0 {
		fmt.Println("No default VPC found.")
		return
	}
	// Print information about the default VPC.
	defaultVPC := result.Vpcs[0]
	fmt.Printf("Default VPC ID: %s\n", awsSDK.StringValue(defaultVPC.VpcId))
	fmt.Printf("CIDR Block: %s\n", awsSDK.StringValue(defaultVPC.CidrBlock))
	fmt.Printf("State: %s\n", awsSDK.StringValue(defaultVPC.State))
	// Print information about subnets in the default VPC.
	fmt.Println("Subnets in the Default VPC:")
	subnets, err := svc.DescribeSubnets(&ec2.DescribeSubnetsInput{
		Filters: []*ec2.Filter{
			{
				Name:   awsSDK.String("vpc-id"),
				Values: []*string{defaultVPC.VpcId},
			},
		},
	})
	if err != nil {
		fmt.Println("Error describing subnets:", err)
		return
	}
	for _, subnet := range subnets.Subnets {
		fmt.Printf("Subnet ID: %s\n", awsSDK.StringValue(subnet.SubnetId))
		fmt.Printf("CIDR Block: %s\n", awsSDK.StringValue(subnet.CidrBlock))
		fmt.Printf("Availability Zone: %s\n", awsSDK.StringValue(subnet.AvailabilityZone))
		fmt.Println("-------------")
	}

	// Create a Secrets Manager service client
	secretsManagerClient := secretsmanager.New(sess)

	// Specify the secret name and secret string
	secretName := "testSecret"
	secretString := `{"username": "test", "password": "password"}`

	// Check if the secret already exists
	secretExists, err := doesSecretExist(secretsManagerClient, secretName)
	if err != nil {
		fmt.Println("Error checking if secret exists:", err)
		return
	}

	if secretExists {
		fmt.Printf("Secret %s already exists. Skipping creation.\n", secretName)
	} else {
		// Create the secret
		createSecretInput := &secretsmanager.CreateSecretInput{
			Name:         awsSDK.String(secretName),
			SecretString: awsSDK.String(secretString),
		}

		createSecretOutput, err := secretsManagerClient.CreateSecret(createSecretInput)
		if err != nil {
			fmt.Println("Error creating secret:", err)
			return
		}

		fmt.Printf("Secret %s created successfully. Version ID: %s\n", secretName, *createSecretOutput.VersionId)
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../code/environments/dev",
		Reconfigure:  true,
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"env_name":              env_name,
			"app_name":              "itest",
			"machine_types":         "t3.xlarge",
			"vpc_id":                awsSDK.StringValue(defaultVPC.VpcId),
			"demoapp_task_memory":   512,
			"demoapp_taks_cpu":      256,
			"desired_service_count": 2,
			"rds_external_secret":   "testSecret",
			"rds_endpoint":          "postgres.c5bseupmzxm1.eu-north-1.rds.amazonaws.com",
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	
	cmd := exec.Command("terraform", "init", "-reconfigure")
	cmd.Dir = "../../code/environments/dev"

	terraform.WorkspaceSelectOrNew(t, terraformOptions, "integration-test")
	terraform.InitAndApply(t, terraformOptions)

	// Setup a TLS configuration to submit with the helper, a blank struct is acceptable
	tlsConfig := tls.Config{}

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 60
	timeBetweenRetries := 45 * time.Second
	// Specify the text the EC2 Instance will return when we make HTTP requests to it.
	instanceText := "Ok"
	// Verify that we get back a 200 OK with the expected instanceText
	http_helper.HttpGetWithRetry(t, fmt.Sprintf("http://%s.devaws.playgroundtech.io/health", "itest"), &tlsConfig, 200, instanceText, maxRetries, timeBetweenRetries)

	// Run `terraform output` to get the value of an output variable
	//taskDefinition := terraform.Output(t, terraformOptions, "task_definition")

	// Look up the ECS cluster by name
	cluster := aws.GetEcsCluster(t, awsRegion, expectedClusterName)
	fmt.Println("ActiveServicesCount ", awsSDK.Int64Value(cluster.ActiveServicesCount))
	assert.Equal(t, int64(1), awsSDK.Int64Value(cluster.ActiveServicesCount))

	// Look up the ECS service by name
	service := aws.GetEcsService(t, awsRegion, expectedClusterName, expectedServiceName)
	fmt.Println("DesiredCount ", awsSDK.Int64Value(service.DesiredCount))
	fmt.Println("LaunchType", awsSDK.StringValue(service.LaunchType))

	assert.Equal(t, int64(2), awsSDK.Int64Value(service.DesiredCount))
	assert.Equal(t, "FARGATE", awsSDK.StringValue(service.LaunchType))

}
