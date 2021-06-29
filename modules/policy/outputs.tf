output "created_sec" {
  value = {for obj in jsondecode(file(var.sec_file)): obj.name => obj }
}

output "created_nat" {
  value = {for group in jsondecode(file(var.nat_file)): group.name => group }
}