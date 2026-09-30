variable "vpc_cidr" {
  description = "Range de IP para criação da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "teste"
}

variable "zones" {
  description = "Zonas de disponibilidade da AWS"
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
}

variable "cidr_private" {
  description = "Range de IP para criação subnet publica"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "cird_public" {
  description = "Range de IP para criação subnet publica"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "ecs_cluster_name" {
  description = "Nome do Cluster ECS"
  type        = string
  default     = "ECS-Fargate"
}

variable "ecr_repository_name" {
  description = "Nome do Repositório ECR para a Aplicação"
  type        = string
  default     = "go-app"
}

variable "ecr_repository_about" {
  description = "Descrição do Repositório ECR para a Aplicação"
  type        = string
  default     = "# GO Consumer SQS"
}

variable "ecr_repository_description" {
  description = "Descrição do Repositório ECR para a Aplicação"
  type        = string
  default     = "Aplicação em GO para consumir mensagens de fila SQS"
}

variable "service_name" {
  description = "Nome do serviço que irá subir no container"
  type        = string
  default     = "dynamodb-api"
}

variable "service_port" {
  description = "Porta do serviço que irá subir no container"
  type        = number
  default     = 7000
}

variable "bucket_name" {
  description = "Nome do bucket S3 onde serão gravados os arquivos"
  type        = string
  default     = "files"
}

variable "sns_name" {
  description = "Nome do tópico SNS para notificar arquivos criados no bucket"
  type        = string
  default     = "notify-s3-object-created"
}

variable "sqs_name" {
  description = "Nome do SQS para notificar a lambda sobre arquivos criados no bucket, ela receberá eventos do SNS"
  type        = string
  default     = "process-s3-object-created"
}
