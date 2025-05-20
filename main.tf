module "aws-prod" {
  source = "./infra"
  instancia = "t4g.xlarge"
  ami_id = "ami-025db40ba9581d621"
  regiao_aws = "eu-west-2"
  chave = "IaC-Production"
  desired_capacity = 2
  min_size = 2
  max_size = 6
  groupName = "IaC-Prod"
  sec_group_name = "alb_full_access"
  AWS_ACCESS_KEY = ""
  AWS_SECRET_KEY = ""
  BUCKET_NAME = ""
  DB_HOST = ""
  DB_NAME = ""
  DB_USER = ""
  DB_PASS = ""
  DB_PORT=5432
  DJANGO_ENV = "prod"
  DJANGO_SECRET_KEY = ""
  DEFAULT_FILE_STORAGE = "storages.backends.s3boto3.S3Boto3Storage"
  BG_REMOVAL_ALLOWED = "1"
  DJANGO_SETTINGS_MODULE = ""
  AWS_STORAGE_BUCKET_NAME = ""
}

