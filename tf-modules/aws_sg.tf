resource "aws_security_group" "minio_multi_node" {
  vpc_id = module.vpc_minio_multi_node.vpc_id
  name   = "${var.common.prefix}-${var.common.env}-minio-multi-node"
}

# インバウンドルール(pingコマンド用)
resource "aws_vpc_security_group_ingress_rule" "icmp" {
  security_group_id = aws_security_group.minio_multi_node.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
}

resource "aws_vpc_security_group_ingress_rule" "ssm" {
  security_group_id = aws_security_group.minio_multi_node.id
  cidr_ipv4         = var.aws_vpc.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "minio" {
  security_group_id = aws_security_group.minio_multi_node.id
  cidr_ipv4         = var.aws_vpc.vpc_cidr
  from_port         = 9000
  to_port           = 9001
  ip_protocol       = "tcp"
}

# アウトバウンドルール
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.minio_multi_node.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
