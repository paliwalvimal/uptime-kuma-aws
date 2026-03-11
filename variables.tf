variable "name_prefix" {
  type        = string
  default     = "vp-"
  description = "Prefix to add to the name of all the resources created by this module"
}

variable "cw_logs_retention_days" {
  type        = number
  default     = 90
  description = "Number of days to retain CloudWatch logs"
}

variable "cw_logs_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ID to use for encrypting CloudWatch logs"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy resources"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to deploy the application load balancer"
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 zone ID in which to create the ALB DNS record"
}

variable "domain_name" {
  type        = string
  description = "Domain name to use for creating ALB DNS record"
}

variable "db_engine_version" {
  type        = string
  default     = "11.8.6"
  description = "Engine version to use for mariadb database"
}

variable "db_family" {
  type        = string
  default     = "mariadb11.8"
  description = "Family for the RDS database"
}

variable "db_instance_type" {
  type        = string
  default     = "db.t4g.small"
  description = "Instance type for the RDS database"
}

variable "db_create_subnet_group" {
  type        = bool
  default     = true
  description = "Whether to create a new subnet group for RDS instance"
}

variable "db_subnet_group_name" {
  type        = string
  default     = ""
  description = "Subnet group name to use for the RDS database"
}

variable "db_subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnet IDs to use for creating db subnet group. Note: Required if `db_create_subnet_group` is set to true"
}

variable "db_allocated_storage" {
  type        = number
  default     = 50
  description = "Allocated storage for the RDS database"
}

variable "db_max_allocated_storage" {
  type        = number
  default     = 500
  description = "Max allocated storage for the RDS database"
}

variable "db_name" {
  type        = string
  default     = "uptime_kuma"
  description = "Default database to create for mariadb"
}

variable "db_username" {
  type        = string
  default     = "admin"
  description = "Master/admin user to create for mariadb"
}

variable "db_password_version" {
  type        = number
  default     = 1
  description = "To change database password, taint the random_password ephemeral resource and update the version number to update database password value in SSM parameter and RDS instance"
}

variable "db_port" {
  type        = number
  default     = 3306
  description = "Port on which mariadb will listen for incomming traffic"
}

variable "db_multi_az" {
  type        = bool
  default     = true
  description = "Whether to create a multi-az RDS instance"
}

variable "db_publicly_accessible" {
  type        = bool
  default     = false
  description = "Whether to create a public facing RDS instance"
}

variable "db_ca_cert_identifier" {
  type        = string
  default     = "rds-ca-rsa2048-g1"
  description = "CA certification to use for the RDS instance"
}

variable "db_auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Whether to auto upgrade minor version for database"
}

variable "db_allow_major_version_upgrade" {
  type        = bool
  default     = false
  description = "Whether to auto upgrade major version for database"
}

variable "db_performance_insights_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable performance insights for RDS instance"
}

variable "db_skip_final_snapshot" {
  type        = bool
  default     = false
  description = "Whether to skip final snapshot before deleting RDS instance"
}

variable "db_enable_deletion_protection" {
  type        = bool
  default     = true
  description = "Whether to enable deletion protection for the RDS instance"
}

variable "db_apply_changes_immediately" {
  type        = bool
  default     = true
  description = "Whether to apply changes to the RDS instance immediately instead of scheduling it"
}

variable "db_maintenance_window" {
  type        = string
  default     = "Sun:00:00-Sun:03:00"
  description = "Maintenance window to set for the RDS instance"
}

variable "db_backup_window" {
  type        = string
  default     = "03:00-06:00"
  description = "Backup window to set for the RDS instance"
}

variable "db_backup_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain the automatic backups"
}

variable "db_cloudwatch_logs_exports" {
  type        = list(string)
  default     = ["general", "audit", "error", "slowquery"]
  description = "List of log types to export to CloudWatch for the RDS instance. Check [AWS doc](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.MariaDB.PublishtoCloudWatchLogs.html) for supported log types"
}

variable "ecs_container_insights_level" {
  type        = string
  default     = "enhanced"
  description = "Container Insights level for ECS cluster. Supported values: `enhanced`, `enabled`, `disabled`"
}

variable "ecs_enable_guardduty_monitoring" {
  type        = bool
  default     = true
  description = "Whether to enable AWS GuardDuty Runtime Monitoring for the ECS cluster"
}

variable "ecs_task_iam_role_policy" {
  type        = string
  default     = ""
  description = "IAM role policy to attach to the ECS task IAM role"
}

variable "ecs_task_family" {
  type        = string
  default     = "uptime-kuma"
  description = "Name of the ECS task family"
}

variable "ecs_task_min_capacity" {
  type        = string
  default     = "1"
  description = "Min number of tasks to always run for the service"
}

variable "ecs_task_max_capacity" {
  type        = string
  default     = "4"
  description = "Max number of tasks to run for the service"
}

variable "ecs_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to deploy the ECS task"
}

variable "ecs_task_appautoscaling_threshold" {
  type        = string
  default     = "60"
  description = "Threshold to use for scaling the service"
}

variable "ecs_uptime_kuma_image" {
  type        = string
  default     = "mirror.gcr.io/louislam/uptime-kuma@sha256:44014bc55a42037105faf371963dda525378cf8866b9b883c38ec18e54b9bd54" # 2.1.3-slim
  description = "Uptime Kuma image to use for the ECS task"
}

variable "ecs_nginx_image" {
  type        = string
  default     = "mirror.gcr.io/nginxinc/nginx-unprivileged@sha256:846c4e33797e325a2f3d623d590610e5da8044fa907db91ce4c80dfa14d1df84" # 1.29-alpine-perl
  description = "Nginx image to use for the ECS task"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of key value pair to assign to resources"
}
