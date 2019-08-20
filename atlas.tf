resource "aws_elastic_beanstalk_application" "cartographer-app" {
  name        = "1d9-cartographer"
  description = "1d9 Astral Atlas Cartographer application"
}

resource "aws_elastic_beanstalk_environment" "cartographer-production" {
  name                = "cartographer-production"
  application         = "${aws_elastic_beanstalk_application.cartographer-app.name}"
  version_label       = "v0.0.4"
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

resource "aws_elastic_beanstalk_environment" "cartographer-staging" {
  name                = "cartographer-staging"
  application         = "${aws_elastic_beanstalk_application.cartographer-app.name}"
  version_label       = "v0.0.4"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.12.14 running Docker 18.06.1-ce"

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "CARTOGRAPHER_CONFIG_PATH"
    value     = "/opt/cartographer/staging.json"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    # Hardcoded value
    value     = "arn:aws:iam::420148351138:instance-profile/AstralAtlasEC2Role"
  }
}