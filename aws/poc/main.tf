terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.72.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "default" {
  default = true
} 

data "external" "get_ip" {
  program = ["/bin/bash" , "${path.module}/get_ip.sh"]
}

resource "aws_security_group" "allow_all_local" {
  name        = "allow_all_local"
  description = "Allow all local traffic"
  vpc_id      =  data.aws_vpc.default.id
  
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self	     = true
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [format("%s/%s",data.external.get_ip.result["internet_ip"],32)]
  }
  
ingress {
    description      = "ELASTIC"
    from_port        = 9200
    to_port          = 9202
    protocol         = "tcp"
    cidr_blocks      = [format("%s/%s",data.external.get_ip.result["internet_ip"],32)]
  }

ingress {
    description      = "GRAFANA"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [format("%s/%s",data.external.get_ip.result["internet_ip"],32)]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_local"
  }
}
