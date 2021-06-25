output "created_addr_obj" {
  value = {for obj in jsondecode(file(var.addr_obj_file)): obj.name => obj }
}

output "created_addr_group" {
  value = {for group in jsondecode(file(var.addr_group_file)): group.name => group }
}