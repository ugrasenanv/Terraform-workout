# Create an AWS Application Load Balancer (ALB) for the ECS service
resource "aws_lb" "alb-client_name" {
  name            = "ECS-FastAPI"                     # Name of the ALB
  security_groups = [aws_security_group.full_access.id]       # Security groups for the ALB
  subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]       # Subnets where the ALB should be deployed

  tags = {
    client  = "client_name"                         
    project = "quiz"
  }
}

# Create an AWS Target Group for the ALB to forward requests to
resource "aws_lb_target_group" "target_lb" {
    name        = "ECS-FastAPI-target"         # Name of the target group
    port        = 8000                                # Port where the ECS service listens
    protocol    = "HTTP"                              # Protocol used for communication
    target_type = "instance"                          # Target type (IP)

    vpc_id      = aws_vpc.vpc.id                    # VPC where the target group should be created

    health_check {
        enabled             = true
        interval            = 60
        path                = "/healthcheck"  # URL path that your application responds to with a 200 status code
        timeout             = 9
        healthy_threshold   = 2
        unhealthy_threshold = 5
    }
  tags = {
    client  = "client_name"                         
    project = "quiz"
  }
}

# Create an ALB listener to route HTTP traffic to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb-client_name.arn                  # ARN of the ALB
  port              = "8000"                          # Port on which the ALB should listen
  protocol          = "HTTP"                          # Protocol used for the listener

  default_action {
      type             = "forward"                    # Forward incoming requests
      target_group_arn = aws_lb_target_group.target_lb.arn # Target group to forward requests to
  }
  tags = {
    client  = "client_name"                         
    project = "quiz"
  }
}

# Output the DNS name of the ALB for external access
output "IP" {
  value = aws_lb.alb-client_name.dns_name
}

resource "aws_launch_template" "machine_aws" {
  name          = "machine-aws"
  image_id      = var.ami_id
  instance_type = var.instancia
  key_name      = var.chave
  tags = {
    Name = "Terraform Ansible Python "
    client  = "client_name"                         
    project = "quiz"
  }
  vpc_security_group_ids = [aws_security_group.private.id]
  user_data = base64encode(templatefile("ansible3.sh", { 
    AWS_CLOUDFRONT_DOMAIN = local.AWS_CLOUDFRONT_DOMAIN, 
    AWS_ACCESS_KEY = var.AWS_ACCESS_KEY, 
    AWS_SECRET_KEY = var.AWS_SECRET_KEY, 
    BUCKET_NAME = var.BUCKET_NAME, 
    regiao_aws = var.regiao_aws }))

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_type = "gp2"
      volume_size = 12
      delete_on_termination = true
    }
  }
}


resource "aws_key_pair" "chaveSSH" {
  key_name = var.chave
  public_key = file("${var.chave}.pub") 
  tags = {
    client  = "client_name"                         
    project = "quiz"
  }
}


locals {
  ansible_hosts = templatefile("${path.module}/hosts.tpl", { dns_name = aws_lb.alb-client_name.dns_name })
}

resource "local_file" "ansible_hosts" {
  content  = local.ansible_hosts
  filename = "${path.module}/hosts.yml"
}