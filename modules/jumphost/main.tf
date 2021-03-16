terraform {
  required_version = ">= 0.13"

}


data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.name}_vpc"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
filter {
    name   = "tag:Name"
    values = [var.subnet_name]
  }
}

data "aws_security_groups" "public" {
   filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "group-name"
    values = ["default"] 
  }
}

data "aws_security_group" "public" {
   filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "group-name"
    values = ["default"] 
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.public.id
}


resource "aws_launch_template" "jumphost" {
  name_prefix   = "jumphost"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  vpc_security_group_ids = data.aws_security_groups.public.ids
  key_name = var.key_name 
}

resource "aws_autoscaling_group" "jumphost" {
  vpc_zone_identifier  = data.aws_subnet_ids.public.ids
  desired_capacity   = 1
  max_size           = 5
  min_size           = 1

  launch_template {
    id      = aws_launch_template.jumphost.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "aws-quickstart-jumphost"
    propagate_at_launch = true
  }
}

# output "private_key_pem" {
#   value = tls_private_key.key.private_key_pem
# }