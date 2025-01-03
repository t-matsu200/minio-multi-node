# 最新のAMI IDを取得
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

# EC2 インスタンス
resource "aws_instance" "minio_multi_node" {
  count = 4
  ami           = var.aws_ec2.ami
  # ami           = data.aws_ami.amzlinux2.id
  instance_type = var.aws_ec2.instance_type
  subnet_id     = module.vpc_minio_multi_node.private_subnets[count.index % length(module.vpc_minio_multi_node.private_subnets)]
  private_ip    = replace(var.aws_vpc.private_subnet_cidr[count.index % length(module.vpc_minio_multi_node.private_subnets)], "0/20", count.index + 5)
  vpc_security_group_ids = [aws_security_group.minio_multi_node.id]

  root_block_device {
    volume_type           = var.aws_ec2.volume_type
    volume_size           = var.aws_ec2.volume_size
    delete_on_termination = var.aws_ec2.delete_on_termination
  }
  ebs_block_device {
    device_name           = var.aws_ec2.ebs_volume1
    volume_type           = var.aws_ec2.volume_type
    volume_size           = var.aws_ec2.volume_size
    delete_on_termination = var.aws_ec2.delete_on_termination
  }
  ebs_block_device {
    device_name           = var.aws_ec2.ebs_volume2
    volume_type           = var.aws_ec2.volume_type
    volume_size           = var.aws_ec2.volume_size
    delete_on_termination = var.aws_ec2.delete_on_termination
  }
  ebs_block_device {
    device_name           = var.aws_ec2.ebs_volume3
    volume_type           = var.aws_ec2.volume_type
    volume_size           = var.aws_ec2.volume_size
    delete_on_termination = var.aws_ec2.delete_on_termination
  }
  ebs_block_device {
    device_name           = var.aws_ec2.ebs_volume4
    volume_type           = var.aws_ec2.volume_type
    volume_size           = var.aws_ec2.volume_size
    delete_on_termination = var.aws_ec2.delete_on_termination
  }

  # インスタンスプロファイルの指定
  iam_instance_profile   = aws_iam_instance_profile.minio_multi_node.name
  user_data = base64encode(templatefile("./scripts/setup.sh", {
    ec2_node_ip1 = replace(var.aws_vpc.private_subnet_cidr[0], "0/20", 5)
    ec2_node_ip2 = replace(var.aws_vpc.private_subnet_cidr[1], "0/20", 6)
    ec2_node_ip3 = replace(var.aws_vpc.private_subnet_cidr[2], "0/20", 7)
    ec2_node_ip4 = replace(var.aws_vpc.private_subnet_cidr[0], "0/20", 8)
    ebs_volume1 = var.aws_ec2.ebs_volume1
    ebs_volume2 = var.aws_ec2.ebs_volume2
    ebs_volume3 = var.aws_ec2.ebs_volume3
    ebs_volume4 = var.aws_ec2.ebs_volume4
  }))
}

# AmazonSSMManagedInstanceCore policyを付加したロールを作成
resource "aws_iam_role" "minio_multi_node" {
  name               = "${var.common.prefix}-${var.common.env}-minio-multi-node"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "policy_ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.minio_multi_node.name
  policy_arn = data.aws_iam_policy.policy_ssm_managed_instance_core.arn
}

# インスタンスプロファイルを作成
resource "aws_iam_instance_profile" "minio_multi_node" {
  name = "${var.common.prefix}-${var.common.env}-minio-multi-node"
  role = aws_iam_role.minio_multi_node.name
}
