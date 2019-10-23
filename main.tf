terraform {
  required_version = "0.12.6"
}

provider "aws" {
  version = "2.23.0"
  region  = "ap-northeast-1"
}

# IAM
module "glue_role" {
  source = "./modules/iam"

  name       = "glue"
  identifier = "glue.amazonaws.com"
  policy     = data.aws_iam_policy.glue_role_policy.policy
}

data "aws_iam_policy" "glue_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Glue
module "glue" {
  source = "./modules/glue"

  bucket        = var.bucket
  glue_role_arn = module.glue_role.iam_role_arn
}

# S3
module "s3" {
  source = "./modules/s3"

  bucket        = var.bucket
  glue_role_arn = module.glue_role.iam_role_arn
}
