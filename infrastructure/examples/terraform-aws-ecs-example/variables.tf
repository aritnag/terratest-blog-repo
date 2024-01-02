# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}
# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name to set for the ECS cluster."
  type        = string
  default     = "terratest-example"
}

variable "service_name" {
  description = "The name to set for the ECS service."
  type        = string
  default     = "terratest-example"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
  default     = "vpc-0f58c2d7e53ca5523"
}

variable "sg_id" {
  default = "sg-06e2a3231083aa068"
}