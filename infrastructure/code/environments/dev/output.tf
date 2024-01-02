

output "universal_security_group" {
  description = "Universal Security Group"
  value       = module.ecs.sg_id
}
output "new_endpoint" {
  value = module.route53.aws_route53_record
}
output "subnet_ids" {
  value = module.alb.subnet_ids
}