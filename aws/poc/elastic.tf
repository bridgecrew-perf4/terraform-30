locals {

  elastic_user_data = templatefile("${path.module}/user-data.yaml", {})

}

resource "aws_instance" "elastic" {
  count = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all_local.id]
  
  root_block_device {
    volume_size = 20
  }

  user_data = local.elastic_user_data

  tags = {
    Name = "elastic-${count.index}"
  }
}


output "aws_instance_elastic" {
    value   = aws_instance.elastic[*].public_ip
}
