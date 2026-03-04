module "alb" {
  source = "github.com/terraform-aws-modules/terraform-aws-alb.git?ref=87f1c9c" # v10.5.0

  name               = "${var.name_prefix}-${local.module_name}"
  vpc_id             = var.vpc_id
  subnets            = var.private_subnet_ids
  internal           = var.internal_alb
  ip_address_type    = "ipv4"
  load_balancer_type = "application"

  # Security Group
  create_security_group      = true
  security_group_name        = "${var.name_prefix}-${local.module_name}-alb"
  security_group_description = "Security group for ${var.name_prefix}-${local.module_name} ALB"
  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "Allow traffic from within the VPC"
      cidr_ipv4   = local.vpc_cidr
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "http"
      }
    }
  }

  target_groups = {
    http = {
      name              = "${var.name_prefix}-${local.module_name}"
      port              = local.ecs_task_nginx_container_port
      protocol          = "HTTP"
      create_attachment = false
      target_type       = "ip"
      health_check = {
        enabled             = true
        path                = "/ping"
        port                = local.ecs_task_nginx_container_port
        protocol            = "HTTP"
        healthy_threshold   = 3
        unhealthy_threshold = 2
      }
    }
  }

  route53_records = {
    a = {
      name    = var.domain_name
      type    = "A"
      zone_id = var.route53_zone_id
    }
  }

  tags = var.tags
}
