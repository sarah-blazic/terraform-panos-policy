###Requirements

---
No requirements.

###Providers

---
Name | Version
-----|------
panos | 1.8.3

###Inputs

---
Name | Description | Type | Default | Required
-----|-----|-----|-----|-----
addr_obj_file | (optional) Path to JSON file that will supply the proper parameters to create address objects.|`string`|`"addr_obj.json"`|no
addr_group_file | (optional) Path to JSON file that will supply the proper parameters to create address groups.|`string`|`"addr_group.json"`|no

###Outputs

---
Name | Description
-----|-----
created_addr_obj |Shows the address objects that were created
created_addr_group |Shows the address groups that were created