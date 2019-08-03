resource "aws_s3_bucket" "cartographer-bucket" {
  bucket = "1d9-atlas-production-bucket"
  acl    = "private"

  tags = {
    project = "1d9"
    env = "production"
  }
}

resource "aws_s3_bucket" "beanstalk-bucket" {
  bucket = "1d9-beanstalk-applications"
  acl    = "private"

  tags = {
    project = "1d9"
    env = "production"
  }
}

resource "aws_s3_bucket_object" "application-object" {
  bucket = "${aws_s3_bucket.beanstalk-bucket.id}"
  key    = "applications/v1.zip"
  source = "artefacts/cartographer.zip"
}

resource "aws_elastic_beanstalk_application" "cartographer-app" {
  name        = "1d9-cartographer"
  description = "1d9 Astral Atlas Cartographer application"
}

resource "aws_elastic_beanstalk_application_version" "v1" {
  name        = "v1"
  application = "${aws_elastic_beanstalk_application.cartographer-app.id}"
  description = "application version created by terraform"
  bucket      = "${aws_s3_bucket.beanstalk-bucket.id}"
  key         = "${aws_s3_bucket_object.application-object.id}"
}