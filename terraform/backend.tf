terraform {
  backend "s3" {
    bucket         = "flask-terraform-state-bucket"
    key            = "terraform/state.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"  # Optional for state locking
  }
}

