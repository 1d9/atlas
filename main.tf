data "external" "package" {
  program = ["node", "scripts/buildPackage.js"]
  query = {
    tag = "latest",
    port = "80",
    authentication = "luke"
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
  name                = "Production (Tome of Worlds - Cartographer)"
  version_label       = "${aws-uncontrolled_elastic_beanstalk_application_version.current-version.application_version_label}"
  application         = "${aws_elastic_beanstalk_application.cartographer.name}"

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
}

output "production-host" {
  value = "${aws_elastic_beanstalk_environment.prod.cname}"
}