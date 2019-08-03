resource "aws_instance" "example" {
  ami           = "ami-0dc96254d5535925f"
  instance_type = "t3a.nano"
}

resource "aws_s3_bucket" "cartographer-bucket" {
  bucket = "1d9-atlas-production-bucket"
  acl    = "private"

  tags = {
    project = "1d9"
    env = "production"
  }
}
