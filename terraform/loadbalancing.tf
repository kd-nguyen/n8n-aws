resource "aws_lb_target_group" "n8n" {
  name        = var.app_name
  port        = 5678
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/healthz"
    port = 5678
  }
}

resource "aws_lb" "n8n" {
  name               = var.app_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.n8n.id]
  subnets            = [for subnet in var.public_subnets : subnet]
}

resource "aws_security_group" "n8n" {
  name        = var.app_name
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ipv4" {
  security_group_id = aws_security_group.n8n.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5678
  ip_protocol       = "tcp"
  to_port           = 5678
}

resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.n8n.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_443" {
  security_group_id = aws_security_group.n8n.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.n8n.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb_listener" "n8n_https" {
  load_balancer_arn = aws_lb.n8n.arn
  port              = "5678"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n.arn
  }
}

resource "aws_lb_listener" "n8n_80" {
  load_balancer_arn = aws_lb.n8n.arn
  port              = "80"


  default_action {
    type = "redirect"

    redirect {
      port        = "5678"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "n8n_443" {
  load_balancer_arn = aws_lb.n8n.arn
  port              = "443"


  default_action {
    type = "redirect"

    redirect {
      port        = "5678"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
