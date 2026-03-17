module "alb" {
  source = "github.com/terraform-aws-modules/terraform-aws-alb.git?ref=87f1c9c" # v10.5.0

  name               = local.resource_name
  vpc_id             = var.vpc_id
  subnets            = var.alb_subnet_ids
  internal           = true
  ip_address_type    = var.alb_ip_address_type
  load_balancer_type = "application"

  create_security_group      = true
  security_group_name        = "${local.resource_name}-alb"
  security_group_description = "Security group for ${local.resource_name} ALB"
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
      name              = local.resource_name
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

  access_logs       = var.alb_access_logs
  connection_logs   = var.alb_connection_logs
  health_check_logs = var.alb_health_check_logs

  desync_mitigation_mode                      = var.alb_desync_mitigation_mode
  drop_invalid_header_fields                  = var.alb_drop_invalid_header_fields
  enable_deletion_protection                  = var.alb_enable_deletion_protection
  enable_http2                                = var.alb_enable_http2
  enable_tls_version_and_cipher_suite_headers = var.alb_enable_tls_version_and_cipher_suite_headers
  enable_waf_fail_open                        = var.alb_enable_waf_fail_open
  enable_xff_client_port                      = var.alb_enable_xff_client_port
  enable_zonal_shift                          = var.alb_enable_zonal_shift
  preserve_host_header                        = var.alb_preserve_host_header
  xff_header_processing_mode                  = var.alb_xff_header_processing_mode

  associate_web_acl = var.alb_web_acl_arn != null
  web_acl_arn       = var.alb_web_acl_arn

  route53_records = {
    a = {
      name    = var.domain_name
      type    = "A"
      zone_id = var.route53_zone_id
    }
  }

  tags = var.tags
}
