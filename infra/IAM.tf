resource "aws_iam_role" "ec2_ssm" {
  name = "ec2_ssm"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ssm_s3_rekognition" {
  name        = "ssm_s3_rekognition"
  description = "Policy to allow EC2 instances to access SSM Parameter Store, S3, and Rekognition"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParameter",
        "s3:*",
        "rekognition:*",
        "autoscaling:DescribeAutoScalingGroups",
        "ec2:DescribeInstances",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces", 
        "ec2:DeleteNetworkInterface",
        "cloudwatch:*",
        "sqs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  tags = {
    client  = "client_name"                         
    project = "quiz"
  }
}
resource "aws_iam_policy" "cloudwatch" {
  name        = "CloudWatchPutMetricData"
  description = "Allows EC2 instances to put metric data to CloudWatch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "cloudwatch:PutMetricData",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "cloudfront_s3_access" {
  name        = "cloudfront_s3_access"
  description = "Allows access to CloudFront distributions and S3 objects"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:GetDistribution",
        "cloudfront:ListDistributions",
        "cloudfront:CreateInvalidation"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_cloudfront_s3_access" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = aws_iam_policy.cloudfront_s3_access.arn
}
resource "aws_iam_role_policy_attachment" "ec2_ssm_s3_rekognition" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = aws_iam_policy.ssm_s3_rekognition.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_cloudwatch" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}

# resource "aws_iam_policy" "sqs_send_receive" {
#   name        = "sqs_send_receive"
#   description = "Allows EC2 instances to send messages to SQS"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": ["sqs:SendMessage", "sqs:ReceiveMessage"],
#       "Resource": "arn:aws:sqs:eu-west-2:357643864089:my-queue.fifo"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "ec2_ssm_sqs_send_receive" {
#   role       = aws_iam_role.ec2_ssm.name
#   policy_arn = aws_iam_policy.sqs_send_receive.arn
# }