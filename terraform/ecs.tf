# define o log group para o cluster
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.ecs_cluster_name}"
  retention_in_days = 7
  tags = {
    Project = "${var.project_name}"
  }
}

# Define o cluster ECS
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_log_group.name
      }
    }
  }
  tags = {
    Project = "${var.project_name}"
  }
}

# Define o capacity provider para o cluster
resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_provider" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
