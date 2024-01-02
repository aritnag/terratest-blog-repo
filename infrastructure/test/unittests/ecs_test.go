package unittests

import (
	"encoding/json"
	"io"
	"os"
	"testing"
	"fmt"
	"math/rand"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
)

// Start of setup

type ECSModuleTestSuite struct {
	suite.Suite
	TerraformOptions *terraform.Options
}

func (suite *ECSModuleTestSuite) SetupSuite() {
	file, _ := os.Open("config.json")
	defer file.Close()
	byteValue, _ := io.ReadAll(file)

	var res map[string]interface{}
	json.Unmarshal([]byte(byteValue), &res)
	// Generate a random number between 0 and 100
	randomNumber := rand.Intn(101)

	// Setup common Teraform options for all tests
	suite.TerraformOptions = &terraform.Options{
		TerraformDir: "../../code/modules/ecs",
		Vars: map[string]interface{}{
			"env_name":                 fmt.Sprintf("%s%d", res["env_name"], randomNumber),
			"vpc_id":                   res["vpc_id"],
			"subnet_ids":               res["subnet_ids"],
			"aws_region":               res["aws_region"],
			"account_id":               res["account_id"],
			"user_data_path":           res["user_data_path"],
			"blogdemo_ecr_image":            fmt.Sprintf("%s%d", res["blogdemo_ecr_image"], randomNumber),
			"aws_lb_target_group_arn":  res["aws_lb_target_group_arn"],
			"machine_types":            res["machine_types"],
			"desired_service_count":            res["desired_service_count"],
			"rds_external_secret":            res["rds_external_secret"],
			"rds_endpoint":            res["rds_endpoint"],

		},
	}

	// Initialize and apply Terraform
	terraform.InitAndApply(suite.T(), suite.TerraformOptions)
}

func (suite *ECSModuleTestSuite) TearDownSuite() {
	// Destroy Terraform resources after all tests
	terraform.Destroy(suite.T(), suite.TerraformOptions)
}

func (suite *ECSModuleTestSuite) TestECSIsCreated() {
	albName := terraform.Output(suite.T(), suite.TerraformOptions, "ecs_service")
	assert.NotNil(suite.T(), albName)
}

func (suite *ECSModuleTestSuite) TestTaskDefinationIsCreated() {
	securityGroupName := terraform.Output(suite.T(), suite.TerraformOptions, "task_definiation")
	assert.NotNil(suite.T(), securityGroupName)
}

func (suite *ECSModuleTestSuite) TestSGIsCreated() {
	listenerARN := terraform.Output(suite.T(), suite.TerraformOptions, "sg_name")
	assert.NotNil(suite.T(), listenerARN)
}

func TestECSModuleTestSuite(t *testing.T) {
	suite.Run(t, new(ECSModuleTestSuite))
} 
 