resource "aws_s3_bucket" "showdown" {
  bucket = "showdown.1d9.tech"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

module "showdown-s3" {
  source = "./github-release-to-s3"

  github_repo_name = "1d9/showdown"
  github_repo_release = "v3.1.0"
  github_repo_release_filename = "dist.zip"
  bucket_name = "showdown.1d9.tech"
}

resource "aws_s3_bucket_object" "showdown_config" {
  acl = "public-read"
  bucket = aws_s3_bucket.showdown.bucket
  key = "config.json"

  content = <<EOT
  {
    "atlasEndpoint": "http://api.tome.1d9.tech",
    "showdownSessionId": "4839c4c3-2dc4-47ce-959b-b489253c348c"
  }
  EOT

  content_type = "application/json"
}

resource "aws_route53_record" "showdown-record" {
  zone_id = "${data.aws_route53_zone.primary-1d9-zone.zone_id}"
  name    = "showdown"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_s3_bucket.showdown.website_endpoint]
}