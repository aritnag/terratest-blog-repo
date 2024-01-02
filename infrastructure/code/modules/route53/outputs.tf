output "aws_route53_record" {
  value = aws_route53_record.alb_dns_record.name
}

