data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  vpc_cidr   = data.aws_vpc.selected.cidr_block

  module_name = "uptime-kuma"

  # ECS task variables
  ecs_task_family                     = local.module_name
  ecs_task_max_capacity               = "4"
  ecs_task_min_capacity               = "1"
  ecs_task_appautoscaling_threshold   = "60"
  ecs_task_uptime_kuma_container_port = 3001
  ecs_task_nginx_container_port       = 8080

  nginx_config_base64 = base64encode(templatefile("${path.module}/nginx.conf.tpl", {
    NGINX_PORT           = local.ecs_task_nginx_container_port
    UPTIME_KUMA_PORT     = local.ecs_task_uptime_kuma_container_port
    UPTIME_KUMA_HOSTNAME = var.domain_name
  }))

  # RDS database variables
  db_name     = "uptime_kuma"
  db_username = "admin"
  db_port     = 3306
}
