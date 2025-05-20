resource "aws_security_group" "full_access" {
  name   = "alb_full_access"
  vpc_id = aws_vpc.vpc.id
}

#Create an ingress rule for the ALB security group, allowing incoming traffic on port 8000 (TCP)
resource "aws_security_group_rule" "tcp_alb" {
  type              = "ingress"
  from_port         = 8000            # Allow traffic from port 8000
  to_port           = 8000            # Allow traffic to port 8000
  protocol          = "tcp"           # Allow TCP protocol
  cidr_blocks       = ["0.0.0.0/0"]   # Allow traffic from any IPv4 source
  security_group_id = aws_security_group.full_access.id
#   cidr_blocks       = [aws_instance.public_instance.public_ip]
}

# Create an egress rule for the ALB security group, allowing all outbound traffic
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0               # Allow traffic from any source port
  to_port           = 0               # Allow traffic to any destination port
  protocol          = "-1"            # Allow any protocol
  cidr_blocks       = ["0.0.0.0/0"]   # Allow traffic to any IPv4 destination
  security_group_id = aws_security_group.full_access.id
}

resource "aws_security_group_rule" "private_egress" {
  type              = "egress"
  from_port         = 0               # Allow traffic from any source port
  to_port           = 0               # Allow traffic to any destination port
  protocol          = "-1"            # Allow any protocol
  cidr_blocks       = ["0.0.0.0/0"]   # Allow traffic to any IPv4 destination
  security_group_id = aws_security_group.private.id
}

# Create an AWS security group for private resources (e.g., ECS tasks)
resource "aws_security_group" "private" {
  name   = "private_ECS"
  vpc_id = aws_vpc.vpc.id
}

# Create an ingress rule for the private security group, allowing traffic from the ALB security group
resource "aws_security_group_rule" "entry_ecs" {
  type                     = "ingress"
  from_port                = 0               # Allow traffic from any source port
  to_port                  = 0               # Allow traffic to any destination port
  protocol                 = "-1"            # Allow any protocol
  source_security_group_id = aws_security_group.full_access.id  # Allow traffic from the ALB security group
  security_group_id        = aws_security_group.private.id
}

resource "aws_security_group_rule" "ssh_access" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #cidr_blocks       = ["92.11.193.226/32"]
  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "allow_http" {
  type             = "ingress"
  from_port        = 8000
  to_port          = 8000
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private.id
}

resource "aws_security_group_rule" "allow_https" {
  type             = "ingress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private.id
}

