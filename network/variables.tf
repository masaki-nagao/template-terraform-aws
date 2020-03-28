variable "cidr" {
  description = "AWS vpc main cidr"
}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "private_subnet_cidrs" {
  type = list(string)
}
variable "subnet_availability_zones" {
  type = list(string)
}
