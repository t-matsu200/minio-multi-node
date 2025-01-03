# VPC
module "vpc_minio_multi_node" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "${var.common.prefix}-${var.common.env}-minio-multi-node"
  cidr   = var.aws_vpc.vpc_cidr
  azs                  = var.aws_vpc.subnet_availability_zones
  public_subnets       = var.aws_vpc.public_subnet_cidr
  private_subnets      = var.aws_vpc.private_subnet_cidr
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
}
