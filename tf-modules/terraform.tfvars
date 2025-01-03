common = {
	prefix = "tmatsuno"
	region = "ap-northeast-1"
	env    = "test"
}

aws_vpc = {
	vpc_cidr = "172.16.0.0/16"
	subnet_availability_zones = [
		"ap-northeast-1a",
		"ap-northeast-1c",
		"ap-northeast-1d"
	]
	public_subnet_cidr = [
		"172.16.0.0/20",
		"172.16.16.0/20",
		"172.16.32.0/20"
	]
	private_subnet_cidr = [
		"172.16.96.0/20",
		"172.16.112.0/20",
		"172.16.128.0/20"
	]
}

aws_ec2 = {
	ami = "ami-0ab02459752898a60"
	instance_type   = "t2.medium"
	volume_size     = 20
	volume_type     = "gp2"
	delete_on_termination = true
	ebs_volume1 = "/dev/xvdf"
	ebs_volume2 = "/dev/xvdg"
	ebs_volume3 = "/dev/xvdh"
	ebs_volume4 = "/dev/xvdi"
}
