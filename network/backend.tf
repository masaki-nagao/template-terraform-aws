terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket  = "m-nagao-terrafrom-tfstate"
    region  = "ap-northeast-1"
    key     = "network/terraform.tfstate"
    encrypt = true
  }
}
