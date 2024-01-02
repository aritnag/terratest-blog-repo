resource "aws_route53_record" "alb_dns_record" {
  zone_id = var.route53_zone_id                     # Replace with your Route 53 hosted zone ID
  name    = "${var.app_name}.${var.route53_domain}" # Replace with your desired subdomain and domain
  type    = "CNAME"
  ttl     = "300" # TTL (Time to Live) in seconds

  records = [var.lb_dns_name]
}

