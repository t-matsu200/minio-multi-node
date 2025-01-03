# vpc endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.vpc_minio_multi_node.vpc_id
  service_name        = "com.amazonaws.${var.common.region}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.minio_multi_node.id]
  subnet_ids          = module.vpc_minio_multi_node.private_subnets
  private_dns_enabled = true
}
 
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = module.vpc_minio_multi_node.vpc_id
  service_name        = "com.amazonaws.${var.common.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.minio_multi_node.id]
  subnet_ids          = module.vpc_minio_multi_node.private_subnets
  private_dns_enabled = true
}
 
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = module.vpc_minio_multi_node.vpc_id
  service_name        = "com.amazonaws.${var.common.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.minio_multi_node.id]
  subnet_ids          = module.vpc_minio_multi_node.private_subnets
  private_dns_enabled = true
}
