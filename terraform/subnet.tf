# cria as subnets públicas
resource "aws_subnet" "public_subnet" {
  count                   = length(var.zones)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cird_public[count.index]
  availability_zone       = var.zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name    = "subnet-${var.project_name}-public-${count.index}"
    Project = "${var.project_name}"
  }
}

# cria as subnets privadas
resource "aws_subnet" "private_subnet" {
  count                   = length(var.zones)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_private[count.index]
  availability_zone       = var.zones[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name    = "subnet-${var.project_name}-private-${count.index}"
    Project = "${var.project_name}"
  }
}
