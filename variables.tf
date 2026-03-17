variable "name_prefix" {
  type        = string
  default     = "vp-"
  description = "Prefix to add to the name of all the resources created by this module"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy resources"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to deploy the application load balancer"
}

variable "alb_ip_address_type" {
  type        = string
  default     = "ipv4"
  description = "Type of IP addresses used by the subnets for your load balancer. **Valid values:** `ipv4`, `dualstack` or `dualstack-without-public-ipv4`"
}

variable "alb_access_logs" {
  type = object({
    bucket  = string
    enabled = optional(bool, true)
    prefix  = optional(string)
  })
  default     = null
  description = "Map containing access logging configuration for the application load balancer"
}

variable "alb_connection_logs" {
  type = object({
    bucket  = string
    enabled = optional(bool, true)
    prefix  = optional(string)
  })
  default     = null
  description = "Map containing connection logging configuration for the application load balancer"
}

variable "alb_health_check_logs" {
  type = object({
    bucket  = string
    enabled = optional(bool, true)
    prefix  = optional(string)
  })
  default     = null
  description = "Map containing health check logging configuration for the application load balancer"
}

variable "alb_desync_mitigation_mode" {
  type        = string
  default     = "defensive"
  description = "Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. **Valid values:** `monitor`, `defensive`, `strictest`"
}

variable "alb_drop_invalid_header_fields" {
  type        = bool
  default     = true
  description = "Whether HTTP headers with invalid header fields are removed by the load balancer (true) or routed to targets (false)"
}

variable "alb_enable_deletion_protection" {
  type        = bool
  default     = true
  description = "Whether to protect deletion of load balancer from accidental deletion"
}

variable "alb_enable_http2" {
  type        = bool
  default     = true
  description = "Whether to enable support for HTTP/2 protocol"
}

variable "alb_enable_tls_version_and_cipher_suite_headers" {
  type        = bool
  default     = false
  description = "Indicates whether the two headers `x-amzn-tls-version` and `x-amzn-tls-cipher-suite`, which contain information about the negotiated TLS version and cipher suite, are added to the client request before sending it to the target"
}

variable "alb_enable_waf_fail_open" {
  type        = bool
  default     = false
  description = "Whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF"
}

variable "alb_enable_xff_client_port" {
  type        = bool
  default     = false
  description = "Whether the X-Forwarded-For header should preserve the source port that the client used to connect to the load balancer"
}

variable "alb_enable_zonal_shift" {
  type        = bool
  default     = true
  description = "Whether zonal shift is enabled"
}

variable "alb_preserve_host_header" {
  type        = bool
  default     = false
  description = "Whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change"
}

variable "alb_xff_header_processing_mode" {
  type        = string
  default     = "append"
  description = "Determines how the load balancer modifies the X-Forwarded-For header in the HTTP request before sending the request to the target. **Valid values:** `append`, `preserve`, and `remove`"
}

variable "alb_web_acl_arn" {
  type        = string
  default     = null
  description = "Web Application Firewall (WAF) ARN of the resource to associate with the load balancer"
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

variable "db_option_group_name" {
  type        = string
  default     = null
  description = "Name of an existing option group to associate to the RDS instance"
}

variable "db_parameter_group_name" {
  type        = string
  default     = null
  description = "Name of an existing parameter group to associate to the RDS instance"
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
  description = "List of subnet IDs to use for creating db subnet group. **Note:** Required if `db_create_subnet_group` is set to true"
}

variable "db_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ARN to use for encrypting the RDS database. If not provided, default KMS key will be used"
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

variable "db_delete_automated_backups" {
  type        = bool
  default     = true
  description = "Whether to delete automated backups immediately after the DB instance is deleted"
}

variable "db_cw_logs_exports" {
  type        = list(string)
  default     = ["general", "audit", "error", "slowquery"]
  description = "List of log types to export to CloudWatch for the RDS instance. Check [AWS doc](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.MariaDB.PublishtoCloudWatchLogs.html) for supported log types"
}

variable "db_cw_log_group_class" {
  type        = string
  default     = "STANDARD"
  description = "Specify the log class of the log group. **Valid values:** `STANDARD`, `INFREQUENT_ACCESS` or `DELIVERY`"
}

variable "db_cw_logs_retention_days" {
  type        = number
  default     = 90
  description = "Number of days to retain CloudWatch logs"
}

variable "db_cw_logs_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ID to use for encrypting CloudWatch logs"
}

variable "db_cw_log_group_skip_destroy" {
  type        = bool
  default     = false
  description = "Set to true if you do not wish the log group to be deleted at destroy time, and instead just remove the log group from the Terraform state"
}

variable "db_monitoring_interval" {
  type        = number
  default     = 0
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, keep it 0"
}

variable "db_monitoring_role_arn" {
  type        = string
  default     = null
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring interval is a non-zero value"
}

# ECS variables
variable "ecs_container_insights_level" {
  type        = string
  default     = "enhanced"
  description = "Container Insights level for ECS cluster. **Valid values:** `enhanced`, `enabled`, `disabled`"
}

variable "ecs_enable_guardduty_monitoring" {
  type        = bool
  default     = true
  description = "Whether to enable AWS GuardDuty Runtime Monitoring for the ECS cluster"
}

variable "ecs_cw_logs_retention_days" {
  type        = number
  default     = 90
  description = "Number of days to retain CloudWatch logs for ECS cluster"
}

variable "ecs_cw_logs_kms_key_id" {
  type        = string
  default     = null
  description = "KMS key ID to use for encrypting CloudWatch logs ECS cluster"
}

variable "ecs_cw_log_group_class" {
  type        = string
  default     = "STANDARD"
  description = "Specify the log class of the log group. **Valid values:** `STANDARD`, `INFREQUENT_ACCESS` or `DELIVERY`"
}

variable "ecs_cw_log_group_skip_destroy" {
  type        = bool
  default     = false
  description = "Set to true if you do not wish the log group to be deleted at destroy time, and instead just remove the log group from the Terraform state"
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
