resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from anywhere"
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
    client  = "client_name"                         
    project = "quiz"
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-0505148b3591e4c07"  # Replace with the AMI ID of your choice
  instance_type = "t2.nano"  # Choose an instance type
  key_name      = var.chave  # Update this with your key pair name

  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true  # Add this line
  user_data = filebase64("terminate_instance.sh")


  tags = {
    Name = "Bastion Host"
    client  = "client_name"                         
    project = "quiz"
  }
}