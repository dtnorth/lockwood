terraform {
  backend "s3" {
    bucket         = "flask-terraform-state-bucket"
    key            = "terraform/state.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    use_lockfile   = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "flask-terraform-state-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
