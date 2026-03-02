terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.1"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

#--------------vpc----------------------------------------------
resource "aws_vpc" "prasadvpc" {
  cidr_block           = "171.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Devops_Vpc"
  }

}
#----------------------------------------------------------------------

#------------------subnet1-----------------------------------------------
resource "aws_subnet" "prasadsubnet1" {
  vpc_id                  = aws_vpc.prasadvpc.id
  cidr_block              = "171.0.0.0/17"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Devops_SUB1"
  }
}
#----------------------------------------------------------------------------
#------------------subnet2-----------------------------------------------
resource "aws_subnet" "prasadsubnet2" {
  vpc_id                  = aws_vpc.prasadvpc.id
  cidr_block              = "171.0.128.0/18"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Devops_SUB2"
  }
}
#----------------------------------------------------------------------------
#------------------subnet3-----------------------------------------------
resource "aws_subnet" "prasadsubnet3" {
  vpc_id                  = aws_vpc.prasadvpc.id
  cidr_block              = "171.0.192.0/27"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Devops_SUB3"
  }
}
#----------------------------------------------------------------------------
#------------------------IGW--------------------------------------------------
resource "aws_internet_gateway" "prasadIGW" {
  vpc_id = aws_vpc.prasadvpc.id
  tags = {
    Name = "Devops-Igw"
  }
}
#------------------------------------------------------------------------------

#-----------------------------------RT----------------------------------------------
resource "aws_route_table" "prasadRT" {
  vpc_id = aws_vpc.prasadvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prasadIGW.id
  }

  tags = {
    Name = "Devops_RT"
  }

}
#----------------------------------------------------------------------------------------

#--------------------------------RT-association1--------------------------------
resource "aws_route_table_association" "prasadasso1" {
  subnet_id      = aws_subnet.prasadsubnet1.id
  route_table_id = aws_route_table.prasadRT.id

}
#---------------------------------------------------------------------------------------
#--------------------------------RT-association2--------------------------------
resource "aws_route_table_association" "prasadasso2" {
  subnet_id      = aws_subnet.prasadsubnet2.id
  route_table_id = aws_route_table.prasadRT.id

}
#---------------------------------------------------------------------------------------
#--------------------------------RT-association3--------------------------------
resource "aws_route_table_association" "prasadasso3" {
  subnet_id      = aws_subnet.prasadsubnet3.id
  route_table_id = aws_route_table.prasadRT.id

}
#---------------------------------------------------------------------------------------
#------------------------SecGRP-----------------------------------------------
resource "aws_security_group" "prasadSG" {
  name   = "Devops_SG"
  vpc_id = aws_vpc.prasadvpc.id

  #inbound
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

  #outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
#-------------------------------------------------------------------------------

#==========================keypair============================================
resource "aws_key_pair" "wwe" {
    key_name = "terraprasad"
    public_key = file("terraprasad.pub")
  
}

#---------------------ec2------------------------------------------------------
resource "aws_instance" "prasadec2" {
  ami                    = "ami-09b041abcb4daa286"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.prasadsubnet1.id
  vpc_security_group_ids = [aws_security_group.prasadSG.id]
  key_name               = aws_key_pair.wwe.id
  user_data              = file("web.sh")
  tags = {
    Name = "Devops_instamce"
  }
}
#--------------------------------------------------------------------------------------
output "public_ip" {
  value = aws_instance.prasadec2.public_ip
}