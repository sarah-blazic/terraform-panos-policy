#antivirus
variable "antivirus_file" {
  type = string
  description = "Path to JSON file that will supply the proper parameters to create the address groups."
  default = "optional"

  validation {
    condition = var.antivirus_file == "optional" || ( fileexists(var.antivirus_file) && ( can(jsondecode(file(var.antivirus_file))) || can(yamldecode(file(var.antivirus_file))) ) )
    error_message = "Not a valid JSON/YAML file to read."
 }
}