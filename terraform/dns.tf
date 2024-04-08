resource "aws_route53_zone" "primary" {
  name = "andy-app.com"
}

resource "aws_route53_record" "n8n" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "n8n-kdn"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.n8n.dns_name}"
    zone_id                = aws_lb.n8n.zone_id
    evaluate_target_health = true
  }
}
