variable "machine_types" {
}

variable "env_name" {
}

variable "aws_region" {
}

variable "blogdemo_ecr_image" {
}

variable "vpc_id" {
}

variable "account_id" {
}

variable "subnet_ids" {
  type = list(string)
}








variable "aws_lb_target_group_arn" {
}

variable "user_data_path" {
  default = "../../modules/ecs/config/user_data.sh"
}

variable "desired_instance_count" {
  default = 2
}

variable "max_instance_count" {
  default = 5
}

variable "desired_service_count" {
}

variable "demoapp_taks_cpu" {
default =  16384
}
variable "demoapp_task_memory" {
  default = 8192

}
variable "rds_external_secret" {
}

variable "rds_endpoint" {
}