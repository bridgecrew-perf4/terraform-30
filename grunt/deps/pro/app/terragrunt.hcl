terraform {
  source = "tfr:///terraform-aws-modules/ec2-instance/aws?version=3.3.0"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  name = "pro-intra-node"
  ami                    = "ami-0ed9277fb7eb570c9"
  instance_type          = "t2.micro"
  key_name               = ""
  vpc_security_group_ids = ["${dependency.vpc.outputs.default_security_group_id}"]
  subnet_id              = "${dependency.vpc.outputs.intra_subnets[0]}"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
