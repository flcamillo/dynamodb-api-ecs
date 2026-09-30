# cria a vpc
resource "aws_vpc" "vpc" {
  cidr_block         = var.vpc_cidr
  enable_dns_support = true
  tags = {
    Name    = "vpc-${var.project_name}-main"
    Project = "${var.project_name}"
  }
}
