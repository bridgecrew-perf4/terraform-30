locals {

  monitoring_user_data = templatefile("${path.module}/user-data.yaml", {})

}

resource "aws_instance" "monitoring" {
  count = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all_local.id]
  
  root_block_device {
    volume_size = 20
  }

  user_data = local.monitoring_user_data

  tags = {
    Name = "monitoring-${count.index}"
  }
}


output "aws_instance_monitoring" {
    value   = aws_instance.monitoring[*].public_ip
}
