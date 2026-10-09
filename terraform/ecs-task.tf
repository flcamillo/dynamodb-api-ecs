locals {

  # define a configuração do otel para a task
  otel_config = templatefile(
    "${path.module}/otel.yaml",
    {
      environment  = var.environment
      service_name = var.service_name
      version      = var.service_version
    }
  )

  # define a configuração da aplicação
  task_application = {
    name      = "${var.service_name}"
    image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.sa-east-1.amazonaws.com/go-app:1.0"
    essential = true
    portMappings = [
      {
        containerPort = var.service_port
        hostPort      = var.service_port
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "OTEL_SERVICE_NAME"
        value = "${var.service_name}"
      },
      {
        name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
        value = "http://localhost:4317"
      },
      {
        name  = "OTEL_RESOURCE_ATTRIBUTES"
        value = "service.name=${var.service_name},service.version=${var.service_version},deployment.environment.name=${var.environment},team=backend,via_resource=abc123,datadog.host.tag.tag_customizada=valor_customizado"
      },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "${aws_cloudwatch_log_group.task_definition_log_group.name}"
        awslogs-region        = "${data.aws_region.current.name}"
        awslogs-stream-prefix = "/ecs/${var.ecs_cluster_name}/app"
      }
    }
  }

  # define a configuração do processo do otel
  task_otel = {
    name      = "otel-collector"
    image     = "otel/opentelemetry-collector-contrib:nightly"
    essential = true
    command = [
      "--config=env:OTEL_CONFIG"
    ]
    environment = [
      {
        name  = "OTEL_CONFIG"
        value = local.otel_config
      },
      {
        name  = "DD_API_KEY"
        value = "77dc229cfc6a3e1462f28e29892dd722"
      },
      {
        name  = "DD_SITE"
        value = "datadoghq.com"
      },
      {
        name  = "DD_TAGS"
        value = "conta:aws,ambiente:desenvolvimento,sistema:ecs,maquina:fargate,env:${var.environment},service:${var.service_name},version:${var.service_version}"
      }
    ]
    portMappings = [
      {
        containerPort = 4317
        protocol      = "tcp"
      },
      {
        containerPort = 4318
        protocol      = "tcp"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "${aws_cloudwatch_log_group.task_definition_log_group.name}"
        awslogs-region        = "${data.aws_region.current.name}"
        awslogs-stream-prefix = "/ecs/${var.ecs_cluster_name}/otel"
      }
    }
  }

  # define a configuração do processo do agente do datadog
  task_datadog = {
    name      = "datadog-agent"
    image     = "public.ecr.aws/datadog/agent:latest"
    essential = true
    portMappings = [
      {
        containerPort = 4317
        hostPort      = 4317
        protocol      = "tcp"
      },
      {
        containerPort = 4318
        hostPort      = 4318
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "DD_API_KEY"
        value = ""
      },
      {
        name  = "DD_SITE"
        value = "datadoghq.com"
      },
      {
        name  = "DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_GRPC_ENDPOINT"
        value = "0.0.0.0:4317"
      },
      {
        name  = "DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_HTTP_ENDPOINT"
        value = "0.0.0.0:4318"
      },
      {
        name  = "DD_OTLP_CONFIG_LOGS_ENABLED"
        value = "true"
      },
      {
        name  = "DD_LOGS_ENABLED"
        value = "true"
      },
      {
        name  = "DD_APM_ENABLED"
        value = "true"
      },
      {
        name  = "DD_PROCESS_AGENT_ENABLED"
        value = "true"
      },
      {
        name  = "DD_DOGSTATSD_NON_LOCAL_TRAFFIC"
        value = "true"
      },
      {
        name  = "DD_ENV"
        value = "dev"
      },
      {
        name  = "DD_TAGS"
        value = "conta:aws ambiente:desenvolvimento sistema:ecs maquina:fargate"
      },
      {
        name  = "DD_OTLP_CONFIG_LOGS_INFRA_ATTRIBUTES_TAGS_AS_DDTAGS"
        value = "true"
      },
      {
        name  = "ECS_FARGATE"
        value = "true"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "${aws_cloudwatch_log_group.task_definition_log_group.name}"
        awslogs-region        = "${data.aws_region.current.name}"
        awslogs-stream-prefix = "/ecs/${var.ecs_cluster_name}/datadog-agent"
      }
    }
  }

}

# define o padrão de tasks que serão executadas
resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.role_task_execution.arn
  task_role_arn            = aws_iam_role.role_task.arn
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    local.task_application,
    local.task_otel,
  ])
  tags = {
    Project = "${var.project_name}"
  }
}

# define o log group para a tarefa
resource "aws_cloudwatch_log_group" "task_definition_log_group" {
  name              = "/ecs/${var.ecs_cluster_name}/${var.service_name}"
  retention_in_days = 7
  tags = {
    Project = "${var.project_name}"
  }
}

# define a política para a tarefa
data "aws_iam_policy_document" "task_execution_policy_doc" {
  statement {
    sid       = "AllowAccessForLogs"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
  }
  statement {
    sid       = "AllowContainerInsights"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "events:PutRule",
      "events:PutTargets",
      "events:DescribeRule",
      "events:ListTargetsByRule",
    ]
  }
  statement {
    sid       = "AllowECRAccess"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:ListTagsForResource"
    ]
  }
  statement {
    sid       = "AllowKMSAccess"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
    ]
  }
  statement {
    sid       = "AllowSecretManagerAccess"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "secretsmanager:GetSecretValue",
    ]
  }
  statement {
    sid       = "AllowSSM"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ssm:GetParameters",
    ]
  }
}

# cria a policy da lambda com os acessos definidos
resource "aws_iam_policy" "task_execution_policy" {
  name        = "${var.ecs_cluster_name}_task_execution_policy"
  policy      = data.aws_iam_policy_document.task_execution_policy_doc.json
  path        = "/"
  description = "Policy para a Task Definition do ECS"
  tags = {
    Project = "${var.project_name}"
  }
}

# define a trusted policy da tarefa
data "aws_iam_policy_document" "task_definition_trusted_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

# cria a role da tarefa com a trusted policy
resource "aws_iam_role" "role_task_execution" {
  name               = "${var.ecs_cluster_name}_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.task_definition_trusted_policy_doc.json
  tags = {
    Project = "${var.project_name}"
  }
}

# associa a role com a policy
resource "aws_iam_role_policy_attachment" "attach_role_task_execution" {
  role       = aws_iam_role.role_task_execution.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}

# define a política para a tarefa
data "aws_iam_policy_document" "task_policy_doc" {
  statement {
    sid       = "SQSConsumeMessages"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
  }
}

# cria a policy da lambda com os acessos definidos
resource "aws_iam_policy" "task_policy" {
  name        = "${var.ecs_cluster_name}_task_policy"
  policy      = data.aws_iam_policy_document.task_policy_doc.json
  path        = "/"
  description = "Policy para a Task Definition do ECS"
  tags = {
    Project = "${var.project_name}"
  }
}

# define a trusted policy da tarefa
data "aws_iam_policy_document" "task_trusted_policy_doc" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

# cria a role da tarefa com a trusted policy
resource "aws_iam_role" "role_task" {
  name               = "${var.ecs_cluster_name}_task_role"
  assume_role_policy = data.aws_iam_policy_document.task_trusted_policy_doc.json
  tags = {
    Project = "${var.project_name}"
  }
}

# associa a role com a policy
resource "aws_iam_role_policy_attachment" "attach_role_task" {
  role       = aws_iam_role.role_task.name
  policy_arn = aws_iam_policy.task_policy.arn
}
