provider "aws" {
  region = "eu-west-1"
}

# 1. Automatically find your Default VPC 
data "aws_vpc" "default" {
  default = true
}

# 2. Find the latest Ubuntu Image [cite: 14]
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

# 3. Create Security Group and LINK to the Default VPC 
resource "aws_security_group" "web_traffic" {
  name        = "allow_web_and_ssh"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = data.aws_vpc.default.id # <--- THIS FIXES THE ERROR 

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

resource "aws_instance" "my_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro" # Switched from t2.micro to t3.micro for Free Tier compatibility
  vpc_security_group_ids = [aws_security_group.web_traffic.id]

  tags = {
    Name = "DBS-Automation-Project"
  }
}