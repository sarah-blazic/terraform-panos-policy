variable "sec_file" {
 type = string
 description = "Path to JSON/YAML file that will supply the proper parameters to create the security policies."
 default = "sec_policy.json"

 validation {
   condition = can(regex("((\\.json)|(\\.yml))$", var.nat_file))
   error_message = "You did not input a valid JSON or YAML file."
 }
}

variable "nat_file" {
 type = string
 description = "Path to JSON/YAML file that will supply the proper parameters to create the NAT policies."
 default = "nat.yml"

 validation {
   condition = can(regex("((\\.json)|(\\.yml))$", var.nat_file))
   error_message = "You did not input a valid JSON or YAML file."
 }
}
