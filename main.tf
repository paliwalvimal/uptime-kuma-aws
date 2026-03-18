data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  vpc_cidr   = data.aws_vpc.selected.cidr_block

  module_name   = "uptime-kuma"
  resource_name = "${var.name_prefix}${local.module_name}"

  # ECS task variables
  ecs_task_uptime_kuma_container_port = 3001
  ecs_task_nginx_container_port       = 8080
  ecs_task_mariadb_ssl_cert_path      = "/app/data"
  ecs_task_nginx_conf_path            = "/etc/nginx"
  ecs_task_nginx_tmp_path             = "/tmp/nginx"

  nginx_config_base64 = base64encode(templatefile("${path.module}/nginx.conf.tpl", {
    NGINX_PORT           = local.ecs_task_nginx_container_port
    UPTIME_KUMA_PORT     = local.ecs_task_uptime_kuma_container_port
    UPTIME_KUMA_HOSTNAME = var.domain_name
  }))
}
