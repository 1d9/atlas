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

resource "aws_s3_bucket_object" "application-v1-object" {
  bucket = "${aws_s3_bucket.beanstalk-bucket.id}"
  key    = "applications/v1.zip"
  source = "artefacts/cartographer.v1.zip"

  etag = "${filemd5("artefacts/cartographer.v1.zip")}"
}
resource "aws_s3_bucket_object" "application-v2-object" {
  bucket = "${aws_s3_bucket.beanstalk-bucket.id}"
  key    = "applications/v2.zip"
  source = "artefacts/cartographer.v2.zip"

  etag = "${filemd5("artefacts/cartographer.v2.zip")}"
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
  key         = "${aws_s3_bucket_object.application-v1-object.id}"
}

resource "aws_elastic_beanstalk_application_version" "v2" {
  name        = "v2"
  application = "${aws_elastic_beanstalk_application.cartographer-app.id}"
  description = "application version created by terraform"
  bucket      = "${aws_s3_bucket.beanstalk-bucket.id}"
  key         = "${aws_s3_bucket_object.application-v2-object.id}"
}

resource "aws_elastic_beanstalk_environment" "cartographer-production" {
  name                = "cartographer-production"
  application         = "${aws_elastic_beanstalk_application.cartographer-app.name}"
  version_label       = "${aws_elastic_beanstalk_application_version.v2.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.12.14 running Docker 18.06.1-ce"

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "CARTOGRAPHER_CONFIG_PATH"
    value     = "/opt/cartographer/production.json"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    # Hardcoded value
    value     = "arn:aws:iam::420148351138:instance-profile/AstralAtlasEC2Role"
  }
}