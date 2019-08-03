resource "aws_s3_bucket" "cartographer-bucket" {
  bucket = "1d9-atlas-production-bucket"
  acl    = "private"

  tags = {
    project = "1d9"
    env = "production"
  }
}

resource "aws_s3_bucket" "1d9-beanstalk-applications" {
  bucket = "1d9-beanstalk-applications"
  acl    = "private"

  tags = {
    project = "1d9"
    env = "production"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "{aws_s3_bucket.1d9-beanstalk-applications.id}"
  key    = "application/v1"
  source = "artefacts/cartographer.zip"
}
