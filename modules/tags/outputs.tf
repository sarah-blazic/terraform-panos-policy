output "created_tags" {
  value = {for tag in jsondecode(file(var.tags_file)): tag.name => tag }
}