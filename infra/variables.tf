variable "regiao_aws" {
  type = string
}
variable "chave" {
    type = string
}
variable "instancia" {
  type = string
}
variable "min_size" {
  type = number
}
variable "max_size" {
  type = number
}
variable "groupName" {
  type = string
}
variable "desired_capacity" {
  type = number
}
variable "sec_group_name" {
  type = string
}
variable "ami_id" {
  type = string
}
variable "AWS_ACCESS_KEY" {
  type = string
  sensitive = true
}

variable "AWS_SECRET_KEY" {
  type = string
  sensitive = true
}
variable "BUCKET_NAME" {
  type = string
  sensitive = true
}
variable "regiao_aws" {
  type = string
  sensitive = true
}
variable "DB_HOST" {
  type = string
  sensitive = true
}
variable "DB_NAME" {
  type = string
  sensitive = true
}
variable "DB_USER" {
  type = string
  sensitive = true
}
variable "DB_PASS" {
  type = string
  sensitive = true
}
variable "DB_PORT" {
  type = string
  sensitive = true
}
variable "DJANGO_ENV" {
  type = string
  sensitive = true
}
variable "DJANGO_SECRET_KEY" {
  type = string
  sensitive = true
}
variable "DEFAULT_FILE_STORAGE" {
  type = string
  sensitive = true
}
variable "BG_REMOVAL_ALLOWED" {
  type = string
  sensitive = true
}
variable "DJANGO_SETTINGS_MODULE" {
  type = string
  sensitive = true
}
variable "AWS_STORAGE_BUCKET_NAME" {
  type = string
  sensitive = true
}

locals {
    AWS_CLOUDFRONT_DOMAIN       = aws_cloudfront_distribution.s3_distribution.domain_name
    CLOUDFRONT_DISTRIBUTION_ID  = aws_cloudfront_distribution.s3_distribution.id
}