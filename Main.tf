terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"

    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_vpc" "jayjay_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "JayjayVPC"
  }
}

resource "aws_subnet" "jayjay_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.jayjay_vpc.id
  availability_zone = "sa-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "JayjaySubnet"
  }
}


resource "aws_internet_gateway" "jayjay_igw" {
  vpc_id = aws_vpc.jayjay_vpc.id
  tags = {
    Name = "JayjayIGW"
  }
}

resource "aws_route_table" "jayjay_rt" {
  vpc_id = aws_vpc.jayjay_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jayjay_igw.id
  }
  tags = {
    Name = "JayjayRouteTable"
  }
}


resource "aws_route_table_association" "jayjay_rta" {
  subnet_id      = aws_subnet.jayjay_subnet.id
  route_table_id = aws_route_table.jayjay_rt.id
}

resource "aws_instance" "app_server" {
  ami           = "ami-00de3f1c465aacb70"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.jayjay_subnet.id
  vpc_security_group_ids = [aws_security_group.jayjay_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "JayjayAppServerInstance"
  }
}

resource "aws_security_group" "jayjay_sg" {
  name        = "jayjay-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.jayjay_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "JayjaySecurityGroup"
  }
}


        