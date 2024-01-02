package main

import (
	"os"

	"github.com/magefile/mage/sh"
)

// Start Localstack
func LSStart() error {
	// Change directory to tests
	os.Chdir("../integrationtests")
	defer os.Chdir("..")
	// Execute command
	if err := sh.RunV("docker-compose", "up", "--build", "--force-recreate", "-d"); err != nil {
		return err
	}
	return nil
}

// Stop Localstack
func LSStop() error {
	// Change directory to tests
	os.Chdir("../integrationtests")
	defer os.Chdir("..")
	// Execute command
	if err := sh.RunV("docker-compose", "down", "-v"); err != nil {
		return err
	}
	if err := sh.RunV("rm", "-r", "volume"); err != nil {
		return err
	}
	return nil
}

// Run tests
func Test() error {
	// Start Localstack
	//LSStart()
	// Change directory to tests
	os.Chdir("../test/integrationtests")
	sh.RunV("go", "mod", "init", "integrationtests")
	sh.RunV("go", "mod", "tidy")
	// Execute command
	if err := sh.RunV("go", "test", "-v", "-timeout", "10m"); err != nil {
		return err
	}
	// Cleanup example directory
	os.Chdir("../test/integrationtests")
	if err := sh.RunV("rm", "-rf", "builds", ".terraform", ".terraform.lock.hcl", "terraform.tfstate", "terraform.tfstate.backup"); err != nil {
		return err
	}
	// Change directory to root
	//os.Chdir("../..")
	// Stop Localstack
	//LSStop()
	return nil
}

// Run pre-commit
func PreCommit() error {
	// Execute command
	if err := sh.RunV("pre-commit", "run", "--all-files"); err != nil {
		return err
	}
	return nil
}
