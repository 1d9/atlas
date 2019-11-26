data "external" "getShowdownGithubRelease" {
  program = ["sh", "./scripts/getGithubRelease.sh"]

  query = {
    repo = "1d9/showdown",
    release = "v2.0.3"
    file = "dist.zip"
  }
}

data "external" "unzipShowdownArchive" {
  program = ["sh", "./scripts/unzipArchive.sh"]

  query = {
    archive = "${data.external.getShowdownGithubRelease.result.file}",
    destination = "showdown",
  }
}

locals {
  showdownDestination = data.external.unzipShowdownArchive.result.destination
  showdownFiles = fileset(local.showdownDestination, "**/*.{png,html,js,otf,css}")
  showdownDomain = "showdown.1d9.tech"
}

resource "aws_s3_bucket" "showdown" {
  bucket = local.showdownDomain
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "showdown_site_files" {
  for_each = local.showdownFiles

  acl = "public-read"
  bucket = aws_s3_bucket.showdown.bucket
  key    = each.value

  source = "${local.showdownDestination}/${each.value}"
  etag =    filemd5("${local.showdownDestination}/${each.value}")

  content_type = local.content-types[element(split(".", each.value), length(split(".", each.value)) - 1)]
}

resource "aws_route53_record" "showdown-record" {
  zone_id = "${data.aws_route53_zone.primary-1d9-zone.zone_id}"
  name    = "showdown"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_s3_bucket.showdown.website_endpoint]
}