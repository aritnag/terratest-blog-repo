output "lb_dns_name" {
  value = aws_lb.ecs_lb_blogdemo.dns_name
}

output "alb_security_group" {
  value = aws_security_group.blogdemo_alb_sg.arn
}


output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.ecs_target_group.arn
}

output "subnet_ids" {
  value = var.subnet_ids
}

