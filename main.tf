resource "aws_security_group" "ephemeral_sg" {
  name        = "ephemeral-sg"
  description = "sg for ephemeral project"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow port 80"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbounds port"
  }

  tags = {
    Name = "ephemeral-sg"
  }
}

resource "aws_instance" "ephemeral_instance" {
  instance_type               = var.ec2_instance_type
  ami                         = var.ec2_ami_id
  vpc_security_group_ids      = [aws_security_group.ephemeral_sg.id]
  subnet_id                   = var.ec2_subnet_id
  associate_public_ip_address = true
  key_name = "ephemeral"

  root_block_device {
    volume_size = var.ec2_root_storage_size
    volume_type = var.ec2_root_storage_type
  }

  tags = {
    Name = "PR-${var.pr_number}"
  }
}

terraform {
  backend "s3" {
   bucket = "ephemeral-backend-khushal" 
   region = "us-east-1"
  }
}


