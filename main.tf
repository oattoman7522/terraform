locals {
  vpc_id           = "vpc-cc40a0aa"
  subnet_id        = "subnet-1ee76447"
  ssh_user         = "ec2-user"
  key_name         = "aws-provision"
  private_key_path = "~/.ssh/aws-provision"


}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region 

}
resource "aws_security_group" "apache" {
  name   = "apache_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "apache" {
  ami                         = "ami-02b6d9703a69265e9"
  subnet_id                   = "subnet-1ee76447"
  instance_type               = "t3a.nano"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.apache.id]
  key_name                    = local.key_name



  provisioner "remote-exec" {
    inline = ["echo Done!"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.apache.public_ip
    }
    
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.apache.public_ip}, --private-key ${local.private_key_path} apache.yaml"
  }
}

output "apache_ip" {
  value = aws_instance.apache.public_ip
}
