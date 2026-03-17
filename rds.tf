resource "aws_security_group" "db" {
  # checkov:skip=CKV2_AWS_5: Associated to RDS database
  name        = "${local.resource_name}-db"
  vpc_id      = var.vpc_id
  description = "Security group for uptime-kuma database"
  tags        = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "db" {
  security_group_id = aws_security_group.db.id
  from_port         = var.db_port
  to_port           = var.db_port
  ip_protocol       = "tcp"
  cidr_ipv4         = local.vpc_cidr
  description       = "Allow connections from entire vpc"
  tags              = var.tags
}

resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.db.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound connections"
  tags              = var.tags
}

ephemeral "random_password" "db_password" {
  length      = 20
  special     = false
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}

resource "aws_ssm_parameter" "db_password" {
  # checkov:skip=CKV_AWS_337: "CMK not required"
  name             = "/rds/${local.resource_name}/password"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.db_password.result
  value_wo_version = var.db_password_version
  tags             = var.tags
}

module "db" {
  source = "github.com/terraform-aws-modules/terraform-aws-rds.git?ref=592cd8b" # v7.1.0

  identifier             = local.resource_name
  engine                 = "mariadb"
  engine_version         = var.db_engine_version
  family                 = var.db_family
  instance_class         = var.db_instance_type
  multi_az               = var.db_multi_az
  publicly_accessible    = var.db_publicly_accessible
  vpc_security_group_ids = [aws_security_group.db.id]
  ca_cert_identifier     = var.db_ca_cert_identifier

  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = false
  password_wo                 = ephemeral.random_password.db_password.result
  password_wo_version         = var.db_password_version
  port                        = var.db_port

  create_db_option_group       = false
  option_group_use_name_prefix = false
  option_group_name            = var.db_option_group_name

  create_db_parameter_group       = false
  parameter_group_use_name_prefix = false
  parameter_group_name            = var.db_parameter_group_name

  create_db_subnet_group          = var.db_create_subnet_group
  db_subnet_group_use_name_prefix = false
  db_subnet_group_name            = coalesce(var.db_subnet_group_name, local.resource_name)
  db_subnet_group_description     = var.db_create_subnet_group ? "Subnet group for ${local.module_name} database" : null
  subnet_ids                      = var.db_create_subnet_group ? var.db_subnet_ids : null

  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.db_kms_key_id
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage

  auto_minor_version_upgrade  = var.db_auto_minor_version_upgrade
  allow_major_version_upgrade = var.db_allow_major_version_upgrade

  maintenance_window       = var.db_maintenance_window
  backup_window            = var.db_backup_window
  backup_retention_period  = var.db_backup_retention_period
  delete_automated_backups = var.db_delete_automated_backups

  performance_insights_enabled           = var.db_performance_insights_enabled
  enabled_cloudwatch_logs_exports        = var.db_cw_logs_exports
  cloudwatch_log_group_class             = var.db_cw_log_group_class
  cloudwatch_log_group_kms_key_id        = var.db_cw_logs_kms_key_id
  cloudwatch_log_group_retention_in_days = var.db_cw_logs_retention_days
  cloudwatch_log_group_skip_destroy      = var.db_cw_log_group_skip_destroy

  monitoring_interval = var.db_monitoring_interval
  monitoring_role_arn = var.db_monitoring_role_arn

  skip_final_snapshot              = var.db_skip_final_snapshot
  final_snapshot_identifier_prefix = local.resource_name
  deletion_protection              = var.db_enable_deletion_protection
  apply_immediately                = var.db_apply_changes_immediately

  tags = var.tags
}
