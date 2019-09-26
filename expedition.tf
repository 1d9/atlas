data "external" "getGithubRelease" {
  program = ["sh", "./scripts/getGithubRelease.sh"]

  query = {
    repo = "astral-atlas/expedition",
    release = "v0.9.0"
    file = "expedition.zip"
  }
}

data "external" "unzipArchive" {
  program = ["sh", "./scripts/unzipArchive.sh"]

  query = {
    archive = "${data.external.getGithubRelease.result.file}",
    destination = "expedition",
  }
}

locals {
  content-types = {
    png = "image/png",
    html = "text/html",
    js = "text/javascript",
    otf = "font/otf",
    css = "text/css"
  }
  destination = data.external.unzipArchive.result.destination
  files = fileset(local.destination, "**/*.{png,html,js,otf,css}")
  domain = "expedition.tome.1d9.tech"
}


resource "aws_s3_bucket" "expedition" {
  bucket = local.domain
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "expedition_site_files" {
  for_each = local.files

  acl = "public-read"
  bucket = aws_s3_bucket.expedition.bucket
  key    = each.value

  source = "${local.destination}/${each.value}"
  etag =    filemd5("${local.destination}/${each.value}")

  content_type = local.content-types[element(split(".", each.value), length(split(".", each.value)) - 1)]
}

resource "aws_route53_record" "expedition-record" {
  zone_id = "${data.aws_route53_zone.primary-1d9-zone.zone_id}"
  name    = local.destination
  type    = "CNAME"
  ttl     = "300"
  records = [aws_s3_bucket.expedition.website_endpoint]
}