# define o serviço para ativar no ecs
resource "aws_ecs_service" "ecs_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  network_configuration {
    subnets          = [for subnet in aws_subnet.public_subnet : subnet.id]
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs.id
    ]
  }
  tags = {
    Project = "${var.project_name}"
  }
}

# security group do ecs
resource "aws_security_group" "ecs" {
  name        = "${var.service_name}-ecs"
  description = "Security group for ECS service"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "Application"
    protocol    = "tcp"
    from_port   = var.service_port
    to_port     = var.service_port
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "OTLP HTTP"
    protocol    = "tcp"
    from_port   = 4318
    to_port     = 4318
    cidr_blocks = [for subnet in aws_subnet.private_subnet : subnet.cidr_block]
  }
  ingress {
    description = "OTLP gRPC"
    protocol    = "tcp"
    from_port   = 4317
    to_port     = 4317
    cidr_blocks = [for subnet in aws_subnet.private_subnet : subnet.cidr_block]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "${var.service_name}-ecs"
    Project = "${var.project_name}"
  }
}
