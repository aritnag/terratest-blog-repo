data "aws_vpc" "blogdemo_vpc" {
  id = var.vpc_id # Replace this with your VPC ID
}
data "aws_subnets" "blogdemo_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "private_subnets" {
  for_each = data.aws_vpc.blogdemo_vpc.tags
  vpc_id   = data.aws_vpc.blogdemo_vpc.id

  filter {
    name   = "tag:Type"
    values = ["Private"]
  }
}

