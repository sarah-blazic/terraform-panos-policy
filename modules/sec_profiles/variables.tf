#Validation checks:
#1) if the var is on default (aka not being used)
#2) a. if the file exists
#   b. if the file can be decoded by jsondecode or yamldecode (the 2 file input options)


#antivirus
variable "antivirus_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.antivirus_file == "optional" || (var.antivirus_file != {} && can(var.antivirus_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}

#file blocking
variable "file_blocking_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.file_blocking_file == "optional" || (var.file_blocking_file != {} && can(var.file_blocking_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}

#anti-spyware
variable "spyware_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.spyware_file == "optional" || (var.spyware_file != {} && can(var.spyware_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}

#vulnerability
variable "vulnerability_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.vulnerability_file == "optional" || (var.vulnerability_file != {} && can(var.vulnerability_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}

#wildfire analysis
variable "wildfire_file" {
  type        = any
  description = "jsondecode and yamldecode with path to JSON/YAML file that will supply the proper parameters to create antivirus profiles."
  default     = "optional"

  validation {
    condition     = var.wildfire_file == "optional" || (var.wildfire_file != {} && can(var.wildfire_file))
    error_message = "Not a valid JSON/YAML file to read."
  }
}