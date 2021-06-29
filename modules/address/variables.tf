//variable "addr_obj_file" {
// type = string
// description = "Path to JSON file that will supply the proper parameters to create the address objects."
// default = "addr_obj.json"
//
// validation {
//   condition = contains(regex("(\\.json)$", var.addr_obj_file), ".json")
//   error_message = "You did not input a valid JSON file."
// }
//}
//
//variable "addr_group_file" {
// type = string
// description = "Path to JSON file that will supply the proper parameters to create the address groups."
// default = "addr_group.json"
//
// validation {
//   condition = contains(regex("(\\.json)$", var.addr_group_file), ".json")
//   error_message = "You did not input a valid JSON file."
// }
//}
