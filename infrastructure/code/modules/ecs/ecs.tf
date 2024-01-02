# Create an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.env_name}-new-blogdemo-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}
## Creates IAM Role which is assumed by the Container Instances (aka EC2 Instances)


resource "aws_iam_policy" "ec2_instance_policy" {
  name        = "blogtemo-${var.env_name}-CustomECSInstancePolicy"
  description = "Custom policy for ECS instance"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ECSPermissions",
        Effect = "Allow",
        Action = [
          "ecs:RegisterContainerInstance",
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:StartTelemetrySession",
          "ecs:UpdateContainerInstancesState",
          "ecs:SubmitAttachmentStateChange",
          "ecs:SubmitContainerStateChange",
          "ecs:SubmitTaskStateChange"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "blogtemo-${var.env_name}-EC2_InstanceRole_dev"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role_attachment" {
  policy_arn = aws_iam_policy.ec2_instance_policy.arn
  role       = aws_iam_role.ec2_instance_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_instance_role_profile" {
  name_prefix = "blogtemo-${var.env_name}_EC2_InstanceRoleProfile_dev"
  role        = aws_iam_role.ec2_instance_role.id
}

data "aws_iam_policy_document" "ec2_instance_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com"
      ]
    }
  }
}

resource "aws_security_group" "ecs_launch_config_sg" {

  name        = "${var.env_name}_ecs_sg"
  vpc_id      = var.vpc_id
  description = "allow http access to demo application api from the v4 world"
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  timeouts {
    delete = "40m"
  }
}

