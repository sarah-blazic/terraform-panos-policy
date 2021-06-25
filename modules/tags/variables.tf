variable "tags_file" {
  type = string
  description = "Path to JSON file that will supply the proper parameters to create the tags."
  default = "tags.json"

  validation {
    condition = contains(regex("(\\.json)$", var.tags_file), ".json")
    error_message = "You did not input a valid JSON file."
  }
}
