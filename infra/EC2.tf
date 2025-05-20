# resource "aws_launch_template" "public_instance_template" {
#   name_prefix   = "public-instance-template"
#   image_id      = "ami-025db40ba9581d621"
#   instance_type = "t4g.small"
#   key_name      = "IaC-Production"

#   vpc_security_group_ids = [aws_security_group.public_instance_sg.id]
#   user_data = templatefile("main_application.sh", { 
#     // your variables here
#   })

#   iam_instance_profile {
#     name = aws_iam_instance_profile.s3_access_profile.name
#   }

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       client  = "client_name"                         
#       project = "quiz"
#       Name = "Public Instance"
#     }
#   }
# }

# resource "aws_autoscaling_group" "public_instance_asg" {
#   desired_capacity   = 1
#   max_size           = 1
#   min_size           = 1
#   health_check_type  = "EC2"
#   launch_template {
#     id      = aws_launch_template.public_instance_template.id
#     version = "$Latest"
#   }

#   vpc_zone_identifier = [aws_subnet.public_subnet_2.id]
# }

resource "aws_security_group_rule" "rule_1" {
  description       = "victor-office"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks       = ["10.44.0.149/32"]
}

resource "aws_security_group_rule" "rule_2" {
  description       = "ec2-instance" 
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks       = ["54.77.25.88/32"]
}

resource "aws_security_group_rule" "rule_3" {
  description       = "ec2-instance" 
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "rule_4" {
  description       = "victor-office2"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks       = ["10.44.3.255/32"]
}

resource "aws_security_group_rule" "rule_5" {
  description       = "victor-home"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks = ["0.0.0.0/0"]
#   cidr_blocks       = ["192.168.1.57/32"]
}
resource "aws_security_group_rule" "rule_6" {
  description       = "Kate"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks       = ["91.69.160.144/32"]
}
resource "aws_security_group_rule" "rule_7" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "rule_8" {
  type              = "ingress"
  from_port         = 5555
  to_port           = 5555
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "rule_9" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http_8000" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access_profile"
  role = aws_iam_role.s3_access_role.name
}

resource "aws_instance" "public_instance" {
  ami           = "ami-025db40ba9581d621"
  instance_type = "t4g.small"
  key_name      = "IaC-Production"

  vpc_security_group_ids = [aws_security_group.public_instance_sg.id]
  subnet_id              = aws_subnet.public_subnet_2.id
  user_data = templatefile("main_application.sh", { 
    AWS_CLOUDFRONT_DOMAIN = local.AWS_CLOUDFRONT_DOMAIN, 
    CLOUDFRONT_DISTRIBUTION_ID  = local.CLOUDFRONT_DISTRIBUTION_ID, 
    AWS_ACCESS_KEY              = var.AWS_ACCESS_KEY,
    AWS_SECRET_KEY              = var.AWS_SECRET_KEY,
    BUCKET_NAME                 = var.BUCKET_NAME,
    regiao_aws                  = var.regiao_aws,
    DB_HOST                     = var.DB_HOST,
    DB_NAME                     = var.DB_NAME,
    DB_USER                     = var.DB_USER,
    DB_PASS                     = var.DB_PASS,
    DB_PORT                     = var.DB_PORT,
    DJANGO_ENV                  = var.DJANGO_ENV,
    DJANGO_SECRET_KEY           = var.DJANGO_SECRET_KEY,
    DEFAULT_FILE_STORAGE        = var.DEFAULT_FILE_STORAGE,
    BG_REMOVAL_ALLOWED          = var.BG_REMOVAL_ALLOWED,
    DJANGO_SETTINGS_MODULE      = var.DJANGO_SETTINGS_MODULE,
    AWS_STORAGE_BUCKET_NAME     = var.AWS_STORAGE_BUCKET_NAME})

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name 

  tags = {
    client  = "client_name"                         
    project = "quiz"
    Name = "Public Instance"
  }
}

resource "aws_security_group" "public_instance_sg" {
  name        = "public_instance_sg"
  description = "Allow inbound traffic from the load balancer"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group_rule" "allow_from_public_instance" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  security_group_id = aws_security_group.public_instance_sg.id
  source_security_group_id = aws_security_group.public_instance_sg.id
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.public_instance.id
  allocation_id = "eipalloc-05a574f2b517228a4"
  # 18.135.57.147
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

