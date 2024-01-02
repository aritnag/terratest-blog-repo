
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}
resource "aws_security_group" "blogdemo_alb_sg" {

  name_prefix = "${var.env_name}_blogdemo_alb_sg_"
  vpc_id      = var.vpc_id
  description = "allow http access to blogdemo api from the v4 world"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  timeouts {
    delete = "40m"
  }
  #depends_on = [aws_iam_role_policy_attachment.sto-lambda-vpc-role-policy-attach]
}

# Create a new Application Load Balancer
resource "aws_lb" "ecs_lb_blogdemo" {
  name               = "${var.env_name}-blogdemo-service"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
}

# Create a target group for the ALB
resource "aws_lb_target_group" "ecs_target_group" {
  name     = "${var.env_name}-blogdemo"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  depends_on = [aws_lb.ecs_lb_blogdemo]
}

# Create a listener for the ALB
resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_lb_blogdemo.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}



