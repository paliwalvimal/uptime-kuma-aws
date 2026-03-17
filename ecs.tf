resource "aws_ecs_cluster" "this" {
  name = local.resource_name

  setting {
    name  = "containerInsights"
    value = var.ecs_container_insights_level
  }

  tags = merge(
    var.tags,
    var.ecs_enable_guardduty_monitoring ? {
      guardDutyRuntimeMonitoringManaged = "true"
    } : {}
  )
}

resource "aws_cloudwatch_log_group" "ecs_task" {
  # checkov:skip=CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year"
  name              = "/ecs/${aws_ecs_cluster.this.name}"
  retention_in_days = var.ecs_cw_logs_retention_days
  kms_key_id        = var.ecs_cw_logs_kms_key_id
  log_group_class   = var.ecs_cw_log_group_class
  skip_destroy      = var.ecs_cw_log_group_skip_destroy
  tags              = var.tags
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.resource_name}-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "ecs_task_execution" {
  # checkov:skip=CKV_AWS_290: "Write access required to allow writing to CloudWatch logs"
  # checkov:skip=CKV_AWS_355: "'*' as a statement's resource is required to allow writing to CloudWatch logs"
  name = "${local.resource_name}-ecs-task-execution"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.ecs_task.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters"
        ]
        Resource = [
          aws_ssm_parameter.db_password.arn
        ]
      }
    ]
  })
}

# IAM role for maptiler ECS task role
resource "aws_iam_role" "ecs_task" {
  name = "${local.resource_name}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:ecs:${local.region}:${local.account_id}:*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "ecs_task" {
  count  = var.ecs_task_iam_role_policy != "" ? 1 : 0
  name   = "${local.resource_name}-ecs-task"
  role   = aws_iam_role.ecs_task.id
  policy = var.ecs_task_iam_role_policy
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.ecs_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      # loads custom nginx config to run nginx proxy as non-root user
      name                   = "nginx-init"
      image                  = "mirror.gcr.io/busybox:stable-musl"
      essential              = false
      readonlyRootFilesystem = true
      privileged             = false
      command = [
        "sh", "-c",
        "echo ${local.nginx_config_base64} | base64 -d | tee ${local.ecs_task_nginx_conf_path}/nginx.conf && chown -R 101:101 ${local.ecs_task_nginx_tmp_path}"
      ]

      mountPoints = [
        {
          sourceVolume  = "nginx-conf"
          containerPath = local.ecs_task_nginx_conf_path
          readOnly      = false
        },
        {
          sourceVolume  = "nginx-tmp"
          containerPath = local.ecs_task_nginx_tmp_path
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "nginx-init"
        }
      }
    },
    {
      # downloads ssl cert to connect to mariadb securely
      name                   = "${var.ecs_task_family}-init"
      image                  = "mirror.gcr.io/busybox:stable-musl"
      essential              = false
      readonlyRootFilesystem = true
      privileged             = false
      command                = ["sh", "-c", "wget -O ${local.ecs_task_mariadb_ssl_cert_path}/global-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem"]

      mountPoints = [{
        sourceVolume  = "${var.ecs_task_family}-data"
        containerPath = local.ecs_task_mariadb_ssl_cert_path
        readOnly      = false
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "${var.ecs_task_family}-init"
        }
      }

      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
          add  = []
        }
      }
    },
    {
      name                   = var.ecs_task_family
      essential              = true
      readonlyRootFilesystem = true
      privileged             = false
      image                  = var.ecs_uptime_kuma_image

      dependsOn = [
        {
          containerName = "${var.ecs_task_family}-init"
          condition     = "SUCCESS"
        }
      ]

      mountPoints = [{
        sourceVolume  = "${var.ecs_task_family}-data"
        containerPath = local.ecs_task_mariadb_ssl_cert_path
        readOnly      = false
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task.name
          awslogs-region        = local.region
          awslogs-stream-prefix = var.ecs_task_family
        }
      }

      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
          add  = []
        }
      }

      portMappings = [{
        appProtocol   = "http"
        containerPort = local.ecs_task_uptime_kuma_container_port
        hostPort      = local.ecs_task_uptime_kuma_container_port
        name          = "${var.ecs_task_family}-${local.ecs_task_uptime_kuma_container_port}-tcp"
        protocol      = "tcp"
      }]

      environment = [
        {
          name  = "UPTIME_KUMA_DB_TYPE"
          value = "mariadb"
        },
        {
          name  = "UPTIME_KUMA_DB_HOSTNAME"
          value = module.db.db_instance_address
        },
        {
          name  = "UPTIME_KUMA_DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "UPTIME_KUMA_DB_NAME"
          value = var.db_name
        },
        {
          name  = "UPTIME_KUMA_DB_USERNAME"
          value = var.db_username
        },
        {
          name  = "UPTIME_KUMA_DB_SSL"
          value = "true"
        },
        {
          name  = "UPTIME_KUMA_DB_CA_FILE"
          value = "${local.ecs_task_mariadb_ssl_cert_path}/global-bundle.pem"
        }
      ]

      secrets = [
        {
          name      = "UPTIME_KUMA_DB_PASSWORD"
          valueFrom = aws_ssm_parameter.db_password.arn
        }
      ]
    },
    {
      name                   = "nginx"
      image                  = var.ecs_nginx_image
      cpu                    = 256
      memory                 = 512
      essential              = true
      readonlyRootFilesystem = true
      privileged             = false

      dependsOn = [
        {
          containerName = "nginx-init"
          condition     = "SUCCESS"
        },
        {
          containerName = var.ecs_task_family
          condition     = "START"
        }
      ]

      portMappings = [{
        containerPort = local.ecs_task_nginx_container_port
        protocol      = "tcp"
      }]

      mountPoints = [
        {
          sourceVolume  = "nginx-conf"
          containerPath = local.ecs_task_nginx_conf_path
          readOnly      = true
        },
        {
          sourceVolume  = "nginx-tmp"
          containerPath = local.ecs_task_nginx_tmp_path
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "nginx"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --spider http://localhost:${local.ecs_task_nginx_container_port}/ping"]
        interval    = 30
        timeout     = 2
        retries     = 3
        startPeriod = 2
      }

      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
          add  = []
        }
      }
    }
  ])

  volume {
    name = "${var.ecs_task_family}-data"
  }
  volume {
    name = "nginx-conf"
  }
  volume {
    name = "nginx-tmp"
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  tags = var.tags
}

resource "aws_security_group" "ecs_task" {
  name        = "${local.resource_name}-ecs-task"
  description = "Security group for ${var.ecs_task_family} ECS task"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "ecs_task_self" {
  security_group_id            = aws_security_group.ecs_task.id
  from_port                    = local.ecs_task_nginx_container_port
  to_port                      = local.ecs_task_nginx_container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_task.id
  description                  = "Allow traffic from resources within the same sg"
  tags                         = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "ecs_task_alb" {
  security_group_id            = aws_security_group.ecs_task.id
  from_port                    = local.ecs_task_nginx_container_port
  to_port                      = local.ecs_task_nginx_container_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = module.alb.security_group_id
  description                  = "Allow traffic from alb sg"
  tags                         = var.tags
}

resource "aws_vpc_security_group_egress_rule" "ecs_task_all" {
  security_group_id = aws_security_group.ecs_task.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound connections"
  tags              = var.tags
}

resource "aws_ecs_service" "this" {
  name                          = var.ecs_task_family
  cluster                       = aws_ecs_cluster.this.arn
  task_definition               = aws_ecs_task_definition.this.arn
  desired_count                 = var.ecs_task_min_capacity
  launch_type                   = "FARGATE"
  availability_zone_rebalancing = "ENABLED"
  force_delete                  = true
  wait_for_steady_state         = true

  network_configuration {
    subnets          = var.ecs_subnet_ids
    security_groups  = [aws_security_group.ecs_task.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["http"].arn
    container_name   = "nginx"
    container_port   = local.ecs_task_nginx_container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.ecs_task_max_capacity
  min_capacity       = var.ecs_task_min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags               = var.tags
}

resource "aws_appautoscaling_policy" "this" {
  name               = var.ecs_task_family
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.ecs_task_appautoscaling_threshold
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
