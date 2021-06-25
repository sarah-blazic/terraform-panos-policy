output "created_services" {
  value = {for service in jsondecode(file(var.services_file)): service.name => service }
}