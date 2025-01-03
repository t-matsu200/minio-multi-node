variable "common" {
  type = object ({
    prefix  = string  # 固有のプレフィクス (任意の文字列)
    region  = string  # リージョン
    env     = string
  })
  description = "リソース共通の設定値"
}

variable "aws_vpc" {
  type = object ({
    vpc_cidr = string  # サブネットの CIDR 範囲
    subnet_availability_zones = list(string) # サブネットのアベイラビリティ ゾーン
    public_subnet_cidr = list(string) # VPCパブリックサブネットの CIDR 範囲
    private_subnet_cidr = list(string) # VPCプライベートサブネットの CIDR 範囲
  })
  description = "AWS VPC の設定値"
}

variable "aws_ec2" {
  type = object ({
    ami = string  # EC2 のAMI
    instance_type   = string
    volume_size     = string
    volume_type     = string
    delete_on_termination = bool   # 実環境を構築する場合は、false にして永続化すること
    ebs_volume1 = string
    ebs_volume2 = string
    ebs_volume3 = string
    ebs_volume4 = string
  })
  description = "AWS EC2 の設定値"
}
