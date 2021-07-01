#Validation checks:
#1) if the var is on default (aka not being used)
#2) a. if the file exists
#   b. if the file can be decoded by jsondecode or yamldecode (the 2 file input options)


#tags
variable "tags_file" {
  type = string
  description = "Path to JSON file that will supply the proper parameters to create tags."
  default = "optional"

  validation { //
    condition =  var.tags_file == "optional" || ( fileexists(var.tags_file) && ( can(jsondecode(file(var.tags_file))) || can(yamldecode(file(var.tags_file))) ) )
    error_message = "Not a valid JSON/YAML file to read."
  }
}


#services
variable "services_file" {
 type = string
 description = "Path to JSON file that will supply the proper parameters to create the services."
  default = "optional"

 validation {
   condition = var.services_file == "optional" || ( fileexists(var.services_file) && ( can(jsondecode(file(var.services_file))) || can(yamldecode(file(var.services_file))) ) )
   error_message = "Not a valid JSON/YAML file to read."
 }
}


#address
variable "addr_obj_file" {
 type = string
 description = "Path to JSON file that will supply the proper parameters to create the address objects."
 default = "optional"

 validation {
   condition = var.addr_obj_file == "optional" || ( fileexists(var.addr_obj_file) && ( can(jsondecode(file(var.addr_obj_file))) || can(yamldecode(file(var.addr_obj_file))) ) )
   error_message = "Not a valid JSON/YAML file to read."
 }
}

variable "addr_group_file" {
 type = string
 description = "Path to JSON file that will supply the proper parameters to create the address groups."
 default = "optional"

 validation {
   condition = var.addr_group_file == "optional" || ( fileexists(var.addr_group_file) && ( can(jsondecode(file(var.addr_group_file))) || can(yamldecode(file(var.addr_group_file))) ) )
   error_message = "Not a valid JSON/YAML file to read."
 }
}


#policy
variable "sec_file" {
 type = string
 description = "Path to JSON/YAML file that will supply the proper parameters to create the security policies."
  default = "optional"

 validation {
   condition = var.sec_file == "optional" || ( fileexists(var.sec_file) &&( can(jsondecode(file(var.sec_file))) || can(yamldecode(file(var.sec_file))) ) )
   error_message = "Not a valid JSON/YAML file to read."
 }
}

variable "nat_file" {
 type = string
 description = "Path to JSON/YAML file that will supply the proper parameters to create the NAT policies."
 default = "optional"

  validation {
   condition = var.nat_file == "optional" || ( fileexists(var.nat_file) && ( can(jsondecode(file(var.nat_file))) || can(yamldecode(file(var.nat_file))) ) )
   error_message = "Not a valid JSON/YAML file to read."
 }
}

