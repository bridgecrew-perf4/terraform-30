include {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=3.11.0"
}

inputs = {
  name = "pro-vpc"
  cidr = "10.200.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  intra_subnets = ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24"]
  public_subnets  = ["10.200.101.0/24", "10.200.102.0/24", "10.200.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
