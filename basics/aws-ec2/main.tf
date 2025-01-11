terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.83.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc_live_tf" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc-live-tf"
    project = "live-tf"
  }
}

resource "aws_subnet" "my_subnet_live_tf" {
  vpc_id     = aws_vpc.my_vpc_live_tf.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "my-subnet-live-tf"
    project = "live-tf"
  }
}

resource "aws_internet_gateway" "my_internet_gateway_live_tf" {
  vpc_id = aws_vpc.my_vpc_live_tf.id

  tags = {
    Name = "my-intertnet-gateway-live-tf"
    project = "live-tf"
  }
}

resource "aws_route_table" "my_route_table_live_tf" {
  vpc_id = aws_vpc.my_vpc_live_tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gateway_live_tf.id
  }

  tags = {
    Name = "my-route-table-live-tf"
    project = "live-tf"
  }
}

resource "aws_main_route_table_association" "my_main_route_table_association_live_tf" {
  vpc_id         = aws_vpc.my_vpc_live_tf.id
  route_table_id = aws_route_table.my_route_table_live_tf.id
}

resource "aws_key_pair" "my_key_pair_live_tf" {
  key_name   = "my-key-pair-live-tf"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_instance" "my_ec2_instance_live_tf" {
  ami           = "ami-05576a079321f21f8"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_key_pair_live_tf.key_name
  associate_public_ip_address = true
  subnet_id = aws_subnet.my_subnet_live_tf.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = {
    Name = "my-ec2-instance-live-tf"
    project = "live-tf"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "SG EC2 Live"
  vpc_id      = aws_vpc.my_vpc_live_tf.id

  ingress {
    description = "Ingress open to all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Egress open to all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all"
    project = "live-tf"
  }
}

output "ec2_ip" {
  value = aws_instance.my_ec2_instance_live_tf.public_ip
}