locals {

  mclb_user_data = templatefile("${path.module}/user-data.yaml", {})

}

resource "aws_instance" "web" {
  count = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all_local.id]
  
  root_block_device {
    volume_size = 20
  }

  user_data = local.mclb_user_data

  tags = {
    Name = "mclb-${count.index}"
  }
}


output "aws_instance_mclb" {
    value   = aws_instance.web[*].public_ip
}
