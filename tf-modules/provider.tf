provider "aws" {
  region = var.common.region
  default_tags {
    tags = {
      Name = "${var.common.prefix}-minio-multi-node"
      Environment = "${var.common.prefix}-${var.common.env}"
    }
  }
}
