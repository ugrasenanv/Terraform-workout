data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "bucket" {
   bucket = "project_name-quiz-1000heads"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = data.aws_s3_bucket.bucket.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowIAMRoleAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.s3_access_role.name}"
            },
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::project_name-quiz-1000heads/keys/*"
        },
        {
            "Sid": "PublicReadAccessMedia",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::project_name-quiz-1000heads/media/*"
        },
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::project_name-quiz-1000heads/static/*"
        },
        {
            "Sid": "AllowAccessFromEC2Instance",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.s3_access_role.name}"
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::project_name-quiz-1000heads/static/*",
                "arn:aws:s3:::project_name-quiz-1000heads/project_name-quiz.js",
                "arn:aws:s3:::project_name-quiz-1000heads/keys/*"
            ]
        }
    ]
}
POLICY
}
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "AllowIAMRoleAccess",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "arn:aws:iam::357643864089:role/ec2_ssm"
#             },
#             "Action": [
#                 "s3:PutObject",
#                 "s3:GetObject",
#                 "s3:DeleteObject"
#             ],
#             "Resource": "arn:aws:s3:::project_name-quiz-1000heads/keys/*"
#         },
#         {
#             "Sid": "PublicReadAccessMedia",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::project_name-quiz-1000heads/media/*"
#         },
#         {
#             "Sid": "PublicReadGetObject",
#             "Effect": "Allow",
#             "Principal": "*",
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::project_name-quiz-1000heads/static/*"
#         },
#         {
#             "Sid": "AllowAccessFromEC2Instance",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "arn:aws:iam::357643864089:role/ec2_ssm"
#             },
#             "Action": "*",
#             "Resource": [
#                 "arn:aws:s3:::project_name-quiz-1000heads/static/*",
#                 "arn:aws:s3:::project_name-quiz-1000heads/project_name-quiz.js",
#                 "arn:aws:s3:::project_name-quiz-1000heads/keys/*"
#             ]
#         }
#     ]
# }