data "aws_vpc" "default" {
  filter {
    name   = "Name"
    values = ["default"]
  }
}
