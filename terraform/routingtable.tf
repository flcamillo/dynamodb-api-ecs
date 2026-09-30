# cria a tabela de roteamento para as subnets publicas
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "rt-${var.project_name}-public"
    Project = "${var.project_name}"
  }
}

# define a rota para saída da internet
resource "aws_route" "route_internet" {
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# associa as subnets publicas na tabela de roteamento
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.route_table_public.id
}

# cria as tabelas de roteamento para as subnets privadas
resource "aws_route_table" "route_table_private" {
  count  = length(var.zones)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "rt-${var.project_name}-private-${count.index}"
    Project = "${var.project_name}"
  }
}

# define a rota para saída da internet
resource "aws_route" "route_private" {
  count                  = length(var.zones)
  route_table_id         = aws_route_table.route_table_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat[count.index].id
}

# associa as subnets publicas na tabela de roteamento
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.route_table_private[count.index].id
}
