


variable "machine_types" {
  default = "c5.xlarge"
}

variable "desired_instance_count" {
  default = 2
}

variable "max_instance_count" {
  default = 5
}

variable "desired_service_count" {
  default = 2
}

variable "demoapp_taks_cpu" {
  default = 8192
}
variable "demoapp_task_memory" {
  default = 16384
}
variable "route53_zone_id" {
  default = "QWERT12345678"
}
variable "route53_domain" {
  default = "demo.myorg.org"
}
variable "env_name" {
  default = "blogexmaple"
}

variable "vpc_id" {
  default = "vpc-0123456789"
}



variable "blogdemo_ecr_image" {
  default = "blogdemo_application_image"
}

variable "aws_region" {
  default = "eu-north-1"
}



variable "sg_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "ssh"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "ssh"
    },
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "test"
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "All"
      cidr_block  = "0.0.0.0/0"
      description = "internal allow"
    }
  ]
}

variable "app_name" {
  type    = string
  default = "demoapp"
}
variable "rds_external_secret" {
  default = "rds!db-01923456-abcd-12323-ddff-33434"
}
variable "rds_endpoint" {
  default = "mydemoapp.myorg.eu-north-1.rds.amazonaws.com"
}