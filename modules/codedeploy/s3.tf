resource "aws_s3_bucket" "build_artifacts_bucket" {
  bucket = "duongdx-build-artifacts-bucket"
}

resource "aws_s3_bucket_versioning" "build_artifacts_bucket_versioning" {
  bucket = aws_s3_bucket.build_artifacts_bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}