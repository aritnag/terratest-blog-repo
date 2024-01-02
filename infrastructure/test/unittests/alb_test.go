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


type ALBModuleTestSuite struct {
	suite.Suite
	TerraformOptions *terraform.Options
}

func (suite *ALBModuleTestSuite) SetupSuite() {
	file, _ := os.Open("config.json")
	defer file.Close()
	byteValue, _ := io.ReadAll(file)

	var res map[string]interface{}
    json.Unmarshal([]byte(byteValue), &res)

	// Generate a random number between 0 and 100
	randomNumber := rand.Intn(101)

	// Setup common Terraform options for all tests
	suite.TerraformOptions = &terraform.Options{
		TerraformDir: "../../code/modules/alb",
		Vars: map[string]interface{}{
			"env_name":   fmt.Sprintf("%s%d", res["env_name"], randomNumber),
			"vpc_id":     res["vpc_id"],
			"sg_id":      res["sg_id"],
			"subnet_ids": res["subnet_ids"],
		},
	}

	// Initialize and apply Terraform
	terraform.InitAndApply(suite.T(), suite.TerraformOptions)
}

func (suite *ALBModuleTestSuite) TearDownSuite() {
	// Destroy Terraform resources after all tests
	terraform.Destroy(suite.T(), suite.TerraformOptions)
}

func (suite *ALBModuleTestSuite) TestALBIsCreated() {
	albName := terraform.Output(suite.T(), suite.TerraformOptions, "lb_dns_name")
	assert.NotNil(suite.T(), albName)
}

func (suite *ALBModuleTestSuite) TestSecurityGroupIsCreated() {
	securityGroupName := terraform.Output(suite.T(), suite.TerraformOptions, "alb_security_group")
	assert.NotNil(suite.T(), securityGroupName)
}

func (suite *ALBModuleTestSuite) TestListenerIsCreated() {
	listenerARN := terraform.Output(suite.T(), suite.TerraformOptions, "aws_lb_target_group_arn")
	assert.NotNil(suite.T(), listenerARN)
}


func TestALBModuleTestSuite(t *testing.T) {
	suite.Run(t, new(ALBModuleTestSuite))
}
