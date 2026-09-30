# cria o internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "ig-${var.project_name}-main"
    Project = "${var.project_name}"
  }
}
