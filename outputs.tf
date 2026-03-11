output "alb_id" {
  value       = module.alb.id
  description = "ID of the application load balancer"
}

output "alb_arn" {
  value       = module.alb.arn
  description = "ARN of the application load balancer"
}

output "alb_dns_name" {
  value       = module.alb.dns_name
  description = "The DNS name of the load balancer"
}

output "alb_security_group_id" {
  value       = module.alb.security_group_id
  description = "ID of the security group associated to the application load balancer"
}

output "alb_security_group_arn" {
  value       = module.alb.security_group_arn
  description = "ARN of the security group associated to the application load balancer"
}

output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.this.arn
  description = "ARN of the ECS cluster"
}

output "ecs_cloudwatch_log_group_arn" {
  value       = aws_cloudwatch_log_group.ecs_task.arn
  description = "ARN of CloudWatch log group created for ECS cluster"
}

output "ecs_task_execution_role_name" {
  value       = aws_iam_role.ecs_task_execution.name
  description = "Name of ECS task execution IAM role"
}

output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution.arn
  description = "ARN of ECS task execution IAM role"
}

output "ecs_task_role_name" {
  value       = aws_iam_role.ecs_task.name
  description = "Name of ECS task IAM role"
}

output "ecs_task_role_arn" {
  value       = aws_iam_role.ecs_task.arn
  description = "ARN of ECS task IAM role"
}

output "ecs_task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "ARN of the task definition including both family and revision"
}

output "ecs_task_definition_arn_no_revision" {
  value       = aws_ecs_task_definition.this.arn_without_revision
  description = "ARN of the task definition without revision"
}

output "ecs_task_definition_revision" {
  value       = aws_ecs_task_definition.this.revision
  description = "Revision of the task definition"
}

output "ecs_security_group_id" {
  value       = aws_security_group.ecs_task.id
  description = "ID of security group created for ECS task"
}

output "ecs_security_group_arn" {
  value       = aws_security_group.ecs_task.arn
  description = "ARN of security group created for ECS task"
}

output "ecs_service_arn" {
  value       = aws_ecs_service.this.arn
  description = "ARN of ECS service"
}

output "db_security_group_id" {
  value       = aws_security_group.db.id
  description = "ID of security group created for RDS instance"
}

output "db_security_group_arn" {
  value       = aws_security_group.db.arn
  description = "ARN of security group created for RDS instance"
}

output "db_ssm_parameter_name" {
  value       = aws_ssm_parameter.db_password.name
  description = "Name of SSM parameter that holds RDS master/admin password"
}

output "db_ssm_parameter_arn" {
  value       = aws_ssm_parameter.db_password.arn
  description = "ARN of SSM parameter that holds RDS master/admin password"
}

output "db_instance_arn" {
  value       = module.db.db_instance_arn
  description = "ARN of RDS instance"
}
