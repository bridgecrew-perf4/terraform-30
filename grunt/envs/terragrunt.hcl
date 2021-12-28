terraform {
  source = "tfr:///terraform-aws-modules/ec2-instance/aws?version=3.3.0"
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF
}
