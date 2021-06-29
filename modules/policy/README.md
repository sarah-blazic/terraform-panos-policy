Requirements
---
No requirements.

Providers
---
Name | Version
-----|------
panos | 1.8.3

Inputs
---
Name | Description | Type | Default | Required
-----|-----|-----|-----|-----
sec_file | (optional) Path to JSON file that will supply the proper parameters to create security policies.|`string`|`"sec_policy.json"`|no
nat_file | (optional) Path to JSON file that will supply the proper parameters to create NAT policies.|`string`|`"nat.json"`|no

Outputs
---
Name | Description
-----|-----
created_sec |Shows the security policies that were created
created_nat |Shows the NAT policies that were created
