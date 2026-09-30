# define o grupo de segurança padrão da vpc
resource "aws_default_security_group" "sg_default" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "sg-${var.project_name}-default"
    Project = "${var.project_name}"
  }
}
