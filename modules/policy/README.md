Requirements
---
* Terraform 0.13+

Providers
---
Name | Version
-----|------
panos | 1.8.3

Inputs
---
Name | Description | Type | Default | Required
-----|-----|-----|-----|-----
tags_file | (optional) Required if tags are used in nat/security policy, services, or address objects/groups. |`string`|n/a|yes
services_file | (optional) Required if services are used in nat/security policy. | `string` | n/a | yes
addr_obj_file | (optional) Required if address objects are used in nat/security policy.|`string`|n/a|yes
addr_group_file | (optional) Required if address groups are used in nat/security.|`string`|n/a|yes
sec_file | (optional) Creates security policies.|`string`|n/a|yes
nat_file | (optional) Creates NAT policies.|`string`|n/a|yes

Outputs
---
Name | Description
-----|-----
created_tags | Shows the tags that were created.
created_services |Shows the services that were created.
created_addr_obj |Shows the address objects that were created.
created_addr_group |Shows the address groups that were created.
created_sec |Shows the security policies that were created.
created_nat |Shows the NAT policies that were created.
