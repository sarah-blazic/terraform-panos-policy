variable "services_file" {
  type = string
  description = "Path to JSON file that will supply the proper parameters to create the services."
  default = "services.json"

  validation {
    condition = contains(regex("(\\.json)$", var.services_file), ".json")
    error_message = "You did not input a valid JSON file."
  }
}