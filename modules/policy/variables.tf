#Validation checks:
#1) if the var is on default (aka not being used)
#2) a. if the file exists
#   b. if the file can be decoded by jsondecode or yamldecode (the 2 file input options)


#tags
variable "tags_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation { //
    condition     = var.tags_file == "optional" || (var.tags_file != {} && can(var.tags_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}


#services
variable "services_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.services_file == "optional" || (var.services_file != {} && can(var.services_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}


#address
variable "addr_obj_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.addr_obj_file == "optional" || (var.addr_obj_file != {} && can(var.addr_obj_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}

variable "addr_group_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.addr_group_file == "optional" || (var.addr_group_file != {} && can(var.addr_group_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}


#policy
variable "sec_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.sec_file == "optional" || (var.sec_file != {} && can(var.sec_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}

variable "nat_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.nat_file == "optional" || (var.nat_file != {} && can(var.nat_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}

