# Initialize Terraform and configure the AWS provider
provider "aws" {
  region = "eu-north-1"
}
terraform {
  backend "s3" {
    bucket = "blogdemo-tf-state-bucket"
    key    = "blogdemo-tf-state"
    region = "eu-north-1"
  }
}
