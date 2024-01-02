output "sg_id" {
  value = aws_security_group.ecs_launch_config_sg.id
}

output "sg_name" {
  value = aws_security_group.ecs_launch_config_sg.name
}

output "ecs_service" {
  value = aws_ecs_service.ecs_service.name
}

output "task_definiation" {
  value = aws_ecs_task_definition.demoapp_service_definition.arn
}
