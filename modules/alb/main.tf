module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.11.0"

  name    = var.alb_name
  vpc_id  = var.vpc_id
  subnets = var.public_subnets

  # Security Group
  security_groups = var.security_groups

  # Listeners
  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = aws_acm_certificate.acm_cert.arn

      weighted_forward = {
        target_groups = [
          {
            target_group_key = "blue-target-group"
            weight           = 100
          },
          {
            target_group_key = "green-target-group"
            weight           = 0
          }
        ]
      }
    }
  }

  # Target Groups
  target_groups = {
    blue-target-group = {
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id   = var.default_instance_id
      health_check = {
        path                = "/"
        protocol            = "HTTP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200-399"
      }
    }

    green-target-group = {
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id   = var.default_instance_id
      health_check = {
        path                = "/"
        protocol            = "HTTP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200-399"
      }
    }
  }

  enable_deletion_protection = false

  # Route53 Record(s)
  route53_records = {
    A = {
      name    = var.application_sub_domain
      type    = "A"
      zone_id = data.aws_route53_zone.selected.id
    }
    AAAA = {
      name    = var.application_sub_domain
      type    = "AAAA"
      zone_id = data.aws_route53_zone.selected.id
    }
  }

  tags = var.tags
}
