provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]

  }
  owners = ["099720109477"]
}


resource "aws_security_group" "notesapi_sg" {
  name        = "notesapi_sg"
  description = "notesAPI security group"
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
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


}

resource "aws_key_pair" "notesapi_key" {
  key_name   = "notesapi-key"
  public_key = file("~/.ssh/notesapi-key.pub")
}


resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.notesapi_key.key_name
  vpc_security_group_ids = [aws_security_group.notesapi_sg.id]

  tags = {
    Name = "notes-api-instance"

  }

}