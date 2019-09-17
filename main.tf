data "external" "package" {
  program = ["node", "scripts/buildPackage.js"]
  query = {
    tag = "v2.4.1",
    authentication = "luke"
    origins = "[\"http://localhost:5000\"]"
  }
}

output "package" {
  value = "${data.external.package.result.filename}"
}

resource "aws_elastic_beanstalk_application" "cartographer" {
  name        = "Tome of Worlds - Cartographer"
  description = "The public API for Tome's Astral Atlas Service"
}

resource "aws_s3_bucket" "app_sources" {
  bucket = "tome-beanstalk-sources"
}

resource "aws-uncontrolled_elastic_beanstalk_application_version" "current-version" {
  application_name = "${aws_elastic_beanstalk_application.cartographer.name}"
  application_store_bucket_name = "${aws_s3_bucket.app_sources.bucket}"
  application_version_filename = "${data.external.package.result.filename}"
}

resource "aws_elastic_beanstalk_environment" "prod" {
  name                = "tow-production"
  version_label       = "${aws-uncontrolled_elastic_beanstalk_application_version.current-version.application_version_label}"
  application         = "${aws_elastic_beanstalk_application.cartographer.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.12.17 running Docker 18.06.1-ce"

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Immutable"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Immutable"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "CARTOGRAPHER_CONFIG_PATH"
    value     = "/opt/cartographer/prod.cartographer.json"
  }
}

data "aws_route53_zone" "primary-1d9-zone" {
  name         = "1d9.tech."
}

resource "aws_route53_record" "api-record" {
  zone_id = "${data.aws_route53_zone.primary-1d9-zone.zone_id}"
  name    = "api.tome.${data.aws_route53_zone.primary-1d9-zone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elastic_beanstalk_environment.prod.cname}"]
}

output "production-host" {
  value = "${aws_elastic_beanstalk_environment.prod.cname}"
}