<!-- BEGIN_TF_DOCS -->
# Uptime Kuma Terraform Module

![License](https://img.shields.io/github/license/paliwalvimal/uptime-kuma-aws-tf?style=for-the-badge) ![Plan](https://img.shields.io/github/actions/workflow/status/paliwalvimal/uptime-kuma-aws-tf/tf-plan.yml?branch=main&label=Plan&style=for-the-badge) ![Checkov](https://img.shields.io/github/actions/workflow/status/paliwalvimal/uptime-kuma-aws-tf/checkov.yml?branch=main&label=Checkov&style=for-the-badge) ![Commit](https://img.shields.io/github/last-commit/paliwalvimal/uptime-kuma-aws-tf?style=for-the-badge) ![Release](https://img.shields.io/github/v/release/paliwalvimal/uptime-kuma-aws-tf?style=for-the-badge)

## Architecture Diagram

![Uptime Kuma Architecture](diagram.jpg)

## Overview

[Uptime Kuma](https://github.com/louislam/uptime-kuma) is a self-hosted monitoring tool to track the availability and response times for web services.

By default, this Terraform module provisions uptime-kuma as a privately hosted service. It runs on AWS ECS Fargate (ARM64) behind an Application Load Balancer, with a MariaDB database hosted on Amazon RDS for persistent storage. An NGINX reverse proxy container is configured in front of Uptime Kuma container to handle HTTP routing and perform health checks.

This terraform module will deploy the following services:
- Route53 Record
- ALB
- ECS Cluster
- RDS MariaDB
- SSM Parameter Store
- IAM Roles

# Usage Instructions
## Example
```hcl
module "uptime_kuma" {
  source = "github.com/paliwalvimal/uptime-kuma-aws-tf.git?ref=" # Always use `ref` to point module to a specific version or hash

  vpc_id          = "vpc-xxxxxxxxxx"
  alb_subnet_ids  = ["subnet-xxxxxxxxxx", "subnet-xxxxxxxxxx"]
  route53_zone_id = "xxxxxxxxxx"
  domain_name     = "example.com"
  db_subnet_ids   = ["subnet-xxxxxxxxxx", "subnet-xxxxxxxxxx"]
  ecs_subnet_ids  = ["subnet-xxxxxxxxxx", "subnet-xxxxxxxxxx"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| aws | >= 6.35.0 |
| random | >= 3.8.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb_access_logs | Map containing access logging configuration for the application load balancer | ```object({ bucket = string enabled = optional(bool, true) prefix = optional(string) })``` | `null` | no |
| alb_connection_logs | Map containing connection logging configuration for the application load balancer | ```object({ bucket = string enabled = optional(bool, true) prefix = optional(string) })``` | `null` | no |
| alb_desync_mitigation_mode | Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. **Valid values:** `monitor`, `defensive`, `strictest` | `string` | `"defensive"` | no |
| alb_drop_invalid_header_fields | Whether HTTP headers with invalid header fields are removed by the load balancer (true) or routed to targets (false) | `bool` | `true` | no |
| alb_enable_deletion_protection | Whether to protect deletion of load balancer from accidental deletion | `bool` | `true` | no |
| alb_enable_http2 | Whether to enable support for HTTP/2 protocol | `bool` | `true` | no |
| alb_enable_tls_version_and_cipher_suite_headers | Indicates whether the two headers `x-amzn-tls-version` and `x-amzn-tls-cipher-suite`, which contain information about the negotiated TLS version and cipher suite, are added to the client request before sending it to the target | `bool` | `false` | no |
| alb_enable_waf_fail_open | Whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF | `bool` | `false` | no |
| alb_enable_xff_client_port | Whether the X-Forwarded-For header should preserve the source port that the client used to connect to the load balancer | `bool` | `false` | no |
| alb_enable_zonal_shift | Whether zonal shift is enabled | `bool` | `true` | no |
| alb_health_check_logs | Map containing health check logging configuration for the application load balancer | ```object({ bucket = string enabled = optional(bool, true) prefix = optional(string) })``` | `null` | no |
| alb_ip_address_type | Type of IP addresses used by the subnets for your load balancer. **Valid values:** `ipv4`, `dualstack` or `dualstack-without-public-ipv4` | `string` | `"ipv4"` | no |
| alb_preserve_host_header | Whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change | `bool` | `false` | no |
| alb_subnet_ids | List of subnet IDs to deploy the application load balancer | `list(string)` | n/a | yes |
| alb_web_acl_arn | Web Application Firewall (WAF) ARN of the resource to associate with the load balancer | `string` | `null` | no |
| alb_xff_header_processing_mode | Determines how the load balancer modifies the X-Forwarded-For header in the HTTP request before sending the request to the target. **Valid values:** `append`, `preserve`, and `remove` | `string` | `"append"` | no |
| db_allocated_storage | Allocated storage for the RDS database | `number` | `50` | no |
| db_allow_major_version_upgrade | Whether to auto upgrade major version for database | `bool` | `false` | no |
| db_apply_changes_immediately | Whether to apply changes to the RDS instance immediately instead of scheduling it | `bool` | `true` | no |
| db_auto_minor_version_upgrade | Whether to auto upgrade minor version for database | `bool` | `true` | no |
| db_backup_retention_period | Number of days to retain the automatic backups | `number` | `7` | no |
| db_backup_window | Backup window to set for the RDS instance | `string` | `"03:00-06:00"` | no |
| db_ca_cert_identifier | CA certification to use for the RDS instance | `string` | `"rds-ca-rsa2048-g1"` | no |
| db_create_subnet_group | Whether to create a new subnet group for RDS instance | `bool` | `true` | no |
| db_cw_log_group_class | Specify the log class of the log group. **Valid values:** `STANDARD`, `INFREQUENT_ACCESS` or `DELIVERY` | `string` | `"STANDARD"` | no |
| db_cw_log_group_skip_destroy | Set to true if you do not wish the log group to be deleted at destroy time, and instead just remove the log group from the Terraform state | `bool` | `false` | no |
| db_cw_logs_exports | List of log types to export to CloudWatch for the RDS instance. Check [AWS doc](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.MariaDB.PublishtoCloudWatchLogs.html) for supported log types | `list(string)` | ```[ "general", "audit", "error", "slowquery" ]``` | no |
| db_cw_logs_kms_key_id | KMS key ID to use for encrypting CloudWatch logs | `string` | `null` | no |
| db_cw_logs_retention_days | Number of days to retain CloudWatch logs | `number` | `90` | no |
| db_delete_automated_backups | Whether to delete automated backups immediately after the DB instance is deleted | `bool` | `true` | no |
| db_enable_deletion_protection | Whether to enable deletion protection for the RDS instance | `bool` | `true` | no |
| db_engine_version | Engine version to use for mariadb database | `string` | `"11.8.6"` | no |
| db_family | Family for the RDS database | `string` | `"mariadb11.8"` | no |
| db_instance_type | Instance type for the RDS database | `string` | `"db.t4g.small"` | no |
| db_kms_key_id | KMS key ARN to use for encrypting the RDS database. If not provided, default KMS key will be used | `string` | `null` | no |
| db_maintenance_window | Maintenance window to set for the RDS instance | `string` | `"Sun:00:00-Sun:03:00"` | no |
| db_max_allocated_storage | Max allocated storage for the RDS database | `number` | `500` | no |
| db_monitoring_interval | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, keep it 0 | `number` | `0` | no |
| db_monitoring_role_arn | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring interval is a non-zero value | `string` | `null` | no |
| db_multi_az | Whether to create a multi-az RDS instance | `bool` | `true` | no |
| db_name | Default database to create for mariadb | `string` | `"uptime_kuma"` | no |
| db_option_group_name | Name of an existing option group to associate to the RDS instance | `string` | `null` | no |
| db_parameter_group_name | Name of an existing parameter group to associate to the RDS instance | `string` | `null` | no |
| db_password_version | To change database password, taint the random_password ephemeral resource and update the version number to update database password value in SSM parameter and RDS instance | `number` | `1` | no |
| db_performance_insights_enabled | Whether to enable performance insights for RDS instance | `bool` | `false` | no |
| db_port | Port on which mariadb will listen for incomming traffic | `number` | `3306` | no |
| db_publicly_accessible | Whether to create a public facing RDS instance | `bool` | `false` | no |
| db_skip_final_snapshot | Whether to skip final snapshot before deleting RDS instance | `bool` | `false` | no |
| db_subnet_group_name | Subnet group name to use for the RDS database | `string` | `""` | no |
| db_subnet_ids | List of subnet IDs to use for creating db subnet group. **Note:** Required if `db_create_subnet_group` is set to true | `list(string)` | `[]` | no |
| db_username | Master/admin user to create for mariadb | `string` | `"admin"` | no |
| domain_name | Domain name to use for creating ALB DNS record | `string` | n/a | yes |
| ecs_container_insights_level | Container Insights level for ECS cluster. **Valid values:** `enhanced`, `enabled`, `disabled` | `string` | `"enhanced"` | no |
| ecs_cw_log_group_class | Specify the log class of the log group. **Valid values:** `STANDARD`, `INFREQUENT_ACCESS` or `DELIVERY` | `string` | `"STANDARD"` | no |
| ecs_cw_log_group_skip_destroy | Set to true if you do not wish the log group to be deleted at destroy time, and instead just remove the log group from the Terraform state | `bool` | `false` | no |
| ecs_cw_logs_kms_key_id | KMS key ID to use for encrypting CloudWatch logs ECS cluster | `string` | `null` | no |
| ecs_cw_logs_retention_days | Number of days to retain CloudWatch logs for ECS cluster | `number` | `90` | no |
| ecs_enable_guardduty_monitoring | Whether to enable AWS GuardDuty Runtime Monitoring for the ECS cluster | `bool` | `true` | no |
| ecs_nginx_image | Nginx image to use for the ECS task | `string` | `"nginxinc/nginx-unprivileged@sha256:eae692a28a027c59cb51e8a991c48ed353cdc4a89cc0a02f86bfd632028a4164"` | no |
| ecs_subnet_ids | List of subnet IDs to deploy the ECS task | `list(string)` | n/a | yes |
| ecs_task_appautoscaling_threshold | Threshold to use for scaling the service | `string` | `"60"` | no |
| ecs_task_family | Name of the ECS task family | `string` | `"uptime-kuma"` | no |
| ecs_task_iam_role_policy | IAM role policy to attach to the ECS task IAM role | `string` | `""` | no |
| ecs_task_max_capacity | Max number of tasks to run for the service | `string` | `"4"` | no |
| ecs_task_min_capacity | Min number of tasks to always run for the service | `string` | `"1"` | no |
| ecs_uptime_kuma_image | Uptime Kuma image to use for the ECS task | `string` | `"louislam/uptime-kuma@sha256:059b49d6473904f2c8cba97582fd37cf4433c069816146e544afe7a7f3687f93"` | no |
| name_prefix | Prefix to add to the name of all the resources created by this module | `string` | `"vp-"` | no |
| route53_zone_id | Route53 zone ID in which to create the ALB DNS record | `string` | n/a | yes |
| tags | A map of key value pair to assign to resources | `map(string)` | `{}` | no |
| vpc_id | ID of the VPC to deploy resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| alb_arn | ARN of the application load balancer |
| alb_dns_name | The DNS name of the load balancer |
| alb_id | ID of the application load balancer |
| alb_security_group_arn | ARN of the security group associated to the application load balancer |
| alb_security_group_id | ID of the security group associated to the application load balancer |
| db_instance_arn | ARN of RDS instance |
| db_security_group_arn | ARN of security group created for RDS instance |
| db_security_group_id | ID of security group created for RDS instance |
| db_ssm_parameter_arn | ARN of SSM parameter that holds RDS master/admin password |
| db_ssm_parameter_name | Name of SSM parameter that holds RDS master/admin password |
| ecs_cloudwatch_log_group_arn | ARN of CloudWatch log group created for ECS cluster |
| ecs_cluster_arn | ARN of the ECS cluster |
| ecs_security_group_arn | ARN of security group created for ECS task |
| ecs_security_group_id | ID of security group created for ECS task |
| ecs_service_arn | ARN of ECS service |
| ecs_task_definition_arn | ARN of the task definition including both family and revision |
| ecs_task_definition_arn_no_revision | ARN of the task definition without revision |
| ecs_task_definition_revision | Revision of the task definition |
| ecs_task_execution_role_arn | ARN of ECS task execution IAM role |
| ecs_task_execution_role_name | Name of ECS task execution IAM role |
| ecs_task_role_arn | ARN of ECS task IAM role |
| ecs_task_role_name | Name of ECS task IAM role |

<!-- END_TF_DOCS -->
