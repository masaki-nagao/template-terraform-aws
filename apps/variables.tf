data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket  = "m-nagao-terrafrom-tfstate"
    region  = "ap-northeast-1"
    key     = "network/terraform.tfstate" 
  }
}

variable "cluster_name" { }
variable "cluster_version" { }

