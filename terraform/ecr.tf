# cria o repositório de imagem para aplicação
resource "aws_ecr_repository" "ecr_go_app" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Project = "${var.project_name}"
  }
}

# define a política de acesso ao repositório de imagens
data "aws_iam_policy_document" "ecr_policy_doc" {
  statement {
    sid    = "AllowRootAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}

# associa a política ao repositório
resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr_go_app.name
  policy     = data.aws_iam_policy_document.ecr_policy_doc.json
}
