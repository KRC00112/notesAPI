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
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
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
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "c7i-flex.large"
  key_name               = aws_key_pair.notesapi_key.key_name
  vpc_security_group_ids = [aws_security_group.notesapi_sg.id]

  tags = {
    Name = "notes-api-instance-${count.index}"

  }

}