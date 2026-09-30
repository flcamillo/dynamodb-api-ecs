# cria o elastic ip para usar no nat gateway
resource "aws_eip" "nat_eip" {
  count  = length(var.zones)
  domain = "vpc"
}

# cria o nat gateway
resource "aws_nat_gateway" "nat" {
  count         = length(var.zones)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  tags = {
    Name    = "ng-${var.project_name}-${count.index}"
    Project = "${var.project_name}"
  }
}
