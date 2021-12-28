include {
  path = find_in_parent_folders()
}

inputs = {
  name = "dev-instance"
  ami                    = "ami-0ed9277fb7eb570c9"
  instance_type          = "t2.micro"
  key_name               = ""
  vpc_security_group_ids = ["sg-074e6424"]
  subnet_id              = "subnet-321ddc54"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
