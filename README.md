# Welcome to demoapp Service project!


## Tech Stacks

- Java Spring Boot
- AWS Components
  - AWS ECS to deploy the application and host the application
- IaaC ( Terraform)

### Replace the following values

- AWS Account ID
- AWS VPC ID
- AWS RDS Endpoint
- AWS RDS External Secret
- AWS Route 53


## File Structure

```bash
├── infrastructure/          # infrastructure definitions
│   └── code 
│       └── modules    
│       └── environment    
│           └── dev    
│   └── test 
│       └── integrationtests 
│       └── unittests 
├── application/         # application codes
```

## Setup

```bash
pipenv install --dev
pipenv shell
pre-commit install
```

## Deploy

```bash
pipenv shell
aws sso login
yawsso -p $AWS_PROFILE  # or manually create credentials for use in terraform
terraform plan
terraform apply

```
