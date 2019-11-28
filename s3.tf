resource "aws_s3_bucket" "obermuller" {
  bucket = "${var.bucket}"
  acl    = "${var.acl}"
  tags = {
    Name = "${var.bucket}-${var.env}"
  }
}

