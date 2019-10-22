variable "bucket" {}
variable "glue_role_arn" {}

resource "aws_glue_catalog_database" "glue_db" {
  name = "legislators-tf"
}

resource "aws_glue_crawler" "glue_crawler" {
  database_name = aws_glue_catalog_database.glue_db.name
  name          = "legislators-crawler"
  role          = var.glue_role_arn

  s3_target {
    path = "s3://awsglue-datasets/examples/us-legislators/all"
  }
}

data "template_file" "glue_app" {
  template = file("${path.module}/glue-scripts/GlueApp.scala.tmpl")

  vars = {
    bucket        = var.bucket
    database_name = aws_glue_catalog_database.glue_db.name
  }
}

resource "local_file" "glue_app" {
  content  = data.template_file.glue_app.rendered
  filename = "${path.module}/glue-scripts/GlueApp.scala"
}

resource "aws_s3_bucket_object" "glue_app" {
  depends_on = ["local_file.glue_app"]
  bucket     = var.bucket
  key        = "glue-scripts/GlueApp.scala"
  source     = local_file.glue_app.filename
  etag       = md5(local_file.glue_app.content)
}

resource "aws_glue_job" "glue_app" {
  name     = "glue-app"
  role_arn = var.glue_role_arn

  command {
    script_location = "s3://${var.bucket}/${aws_s3_bucket_object.glue_app.key}"
  }

  default_arguments = {
    "--job-language"        = "scala"
    "--class"               = "GlueApp"
    "--job-bookmark-option" = "job-bookmark-enable"
  }
}
