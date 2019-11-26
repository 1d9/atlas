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
  github_repo_release = "v3.0.1"
  github_repo_release_filename = "dist.zip"
  bucket_name = "showdown.1d9.tech"
}

resource "aws_route53_record" "showdown-record" {
  zone_id = "${data.aws_route53_zone.primary-1d9-zone.zone_id}"
  name    = "showdown"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_s3_bucket.showdown.website_endpoint]
}