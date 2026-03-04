variable "name_prefix" {
  type        = string
  default = "vp-"
  description = "Prefix to be added to the name of the resources"
}

variable "cw_logs_retention_days" {
  type        = number
  default     = 90
  description = "Retention days for CloudWatch logs"
}

variable "cw_logs_kms_key_id" {
  type        = string
  default = null
  description = "KMS key ID to use for encrypting CloudWatch logs"
}

variable "ecs_task_iam_role_policy" {
  type        = string
  default     = ""
  description = "IAM role policy to attach to the ECS task IAM role"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy the ECS task security group"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs to deploy the ECS task"
}

variable "data_subnet_ids" {
  type        = list(string)
  description = "List of data subnet IDs to deploy the RDS database"
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 zone ID to create the ALB DNS record"
}

variable "domain_name" {
  type        = string
  description = "Domain name to be used for the ALB DNS record"
}

variable "db_engine_version" {
  type        = string
  default = "11.8.6"
  description = "Engine version for the RDS database"
}

variable "db_family" {
  type        = string
  default = "mariadb11.8"
  description = "Family for the RDS database"
}

variable "db_instance_type" {
  type        = string
  default = "db.t4g.small"
  description = "Instance type for the RDS database"
}

variable "db_allocated_storage" {
  type        = number
  default = 50
  description = "Allocated storage for the RDS database"
}

variable "db_max_allocated_storage" {
  type        = number
  default = 500
  description = "Max allocated storage for the RDS database"
}

variable "uptime_kuma_image" {
  type        = string
  default = "mirror.gcr.io/louislam/uptime-kuma@sha256:44014bc55a42037105faf371963dda525378cf8866b9b883c38ec18e54b9bd54"  # 2.1.3-slim
  description = "Uptime Kuma image to use for the ECS task"
}

variable "nginx_image" {
  type        = string
  default = "mirror.gcr.io/nginxinc/nginx-unprivileged@sha256:846c4e33797e325a2f3d623d590610e5da8044fa907db91ce4c80dfa14d1df84" # 1.29-alpine-perl
  description = "Nginx image to use for the ECS task"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of key value pair to assign to resources"
}
