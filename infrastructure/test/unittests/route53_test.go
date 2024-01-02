package unittests

import (
	"testing"
	"encoding/json"
	"io"
	"os"
	"fmt"
	"math/rand"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
)

// Start of setup

type Route53ModuleTestSuite struct {
	suite.Suite
	TerraformOptions *terraform.Options
}

func (suite *Route53ModuleTestSuite) SetupSuite() {
	file, _ := os.Open("config.json")
	defer file.Close()
	byteValue, _ := io.ReadAll(file)

	var res map[string]interface{}
    json.Unmarshal([]byte(byteValue), &res)
	// Generate a random number between 0 and 100
	randomNumber := rand.Intn(101)

	// Setup common Teraform options for all tests
	suite.TerraformOptions = &terraform.Options{
		TerraformDir: "../../code/modules/route53",
		Vars: map[string]interface{}{
			"env_name":        fmt.Sprintf("%s%d", res["env_name"], randomNumber),
			"route53_zone_id": res["route53_zone_id"],
			"route53_domain":  res["route53_domain"],
			"lb_dns_name":     res["lb_dns_name"],
			"app_name":     res["app_name"],
		},
	}

	// Initialize and apply Terraform
	terraform.InitAndApply(suite.T(), suite.TerraformOptions)
}

func (suite *Route53ModuleTestSuite) TearDownSuite() {
	// Destroy Terraform resources after all tests
	terraform.Destroy(suite.T(), suite.TerraformOptions)
}

func (suite *Route53ModuleTestSuite) TestDNSRecordIsCreated() {
	awsRoute53Record := terraform.Output(suite.T(), suite.TerraformOptions, "aws_route53_record")
	assert.NotNil(suite.T(), awsRoute53Record)
}

func TestRoute53ModuleTestSuite(t *testing.T) {
	suite.Run(t, new(Route53ModuleTestSuite))
}
