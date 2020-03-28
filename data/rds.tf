output "default_vpc_id" {
  value = data.terraform_remote_state.network.outputs.default_vpc_id
}
