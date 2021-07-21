Palo Alto Networks Panorama Policy Module for Policy as Code
---
This Terraform module allows users to configure policies (NAT and Security Policies) along with tags, address objects, address groups, and services with Palo Alto Networks **PAN-OS** based PA-Series devices.

Feature
---
This module supports the following:
* Create, update, and delete policies based on a JSON/YAML document.

What is Policy as Code?
---
Policy as Code is a way to configure Palo Alto Networks’ Next Generation Firewalls and Panoramas without needing to use the GUI.

![PolicyAsCode](https://i.imgur.com/hSWGYuL.png)

* Policy as Code executes Terraform that will create a variety of resources based on the file input. 
* Terraform is the underlying automation tool, therefore it utilizes the Terraform provider ecosystem to drive relevant change to the network infrastructure.
* All Policy as Code is written as a compatible **Terraform module** using resources for the underlying network infrastructure provider.

Requirements
---
* Terraform 0.13+

Providers
---
Name | Version
-----|------
panos | 1.8.3

Compatibility
---
This module is meant for use with **PAN-OS >= 8.0** and **Terraform >= 0.13**

Permissions
---
* In order for the module to work as expected, the hostname, username, and password to the **panos** Terraform provider.

Caveats
---
* Tags, address objects, address groups, and services can be associated to one or more polices on a PAN-OS device. Once any tags, address objects, address groups, or/and services are associated to a policy, it can only be deleted if there are no policies associated with any of those resources. If the users tries to delete any of those resources that are associated with any policy, they will encounter an error. This is a behavior on a PAN-OS device. This module creates, updates and deletes polices with Terraform. If a security profile, tag, address object, address group, and/or service associated to a security policy is deleted from the panorama, the module will throw an error when trying to create the profile. This is the correct and expected behavior as the resource is being used in a policy.

Usage
---
1. Create a JSON/YAML file to config one or more of the following: tags, address objects, address groups, services, nat rules, and security policy. Please note that the file(s) must adhere to its respective schema.

Below is an example of a JSON file to create Tags.
```json
[
  {
    "name": "trust"
  },
  {
    "name": "untrust",
    "comment": "for untrusted zones",
    "color": "color4"
  },
  {
    "name": "AWS",
    "device_group": "AWS",
    "color": "color8"
  }
]
```

Below is an example of a YAML file to create Tags.
```yaml
---
- name: trust
- name: untrust
  comment: for untrusted zones
  color: color4
- name: AWS
  device_group: AWS
  color: color8
```
2. **(recommended)** Add **tlint.yml**, **"opa.yml"**, and **"validate.yml"** to .github/workflows with changes to file paths in opa.yml and validate.yml depending on the repo.
* **tlint.yml** : checks to see if the Terraform has errors (like illegal instance types) for Major Cloud providers (AWS/Azure/GCP), warns about deprecated syntax, unused declarations, and enforces best practices, naming conventions.
```yaml
name: terraform-lint

on: [push, pull_request]

jobs:
  delivery:

    runs-on: ubuntu-latest

    steps:
    - name: Check out code
      uses: actions/checkout@main
    - name: Lint Terraform
      uses: actionshub/terraform-lint@main

```

* **opa.yml** : checks JSON for duplicate names.
```yaml
name: Check for JSON duplicates
on: [push]

jobs:
  opa_eval:
    runs-on: ubuntu-latest
    name: Open Policy Agent
    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Evaluate OPA Policy w/tags
      id: opa_eval_tags
      uses: migara/test-action@master
      with:
        tests: ./validate/opa/panos.rego
        policy: ./examples/files/json/tags.json #path to tags file
        
    - name: Print Results tags
      run: |
       echo $opa_results | jq -r '.result[].expressions[].value'
      env:
       opa_results: ${{ steps.opa_eval_tags.outputs.opa_results }}

    - name: Evaluate OPA Policy w/addr_obj
      id: opa_eval_addr_obj
      uses: migara/test-action@master
      with:
        tests: ./validate/opa/panos.rego
        policy: ./examples/files/json/addr_obj.json #path to address objects file
        
    - name: Print Results addr_obj
      run: |
       echo $opa_results | jq -r '.result[].expressions[].value'
      env:
       opa_results: ${{ steps.opa_eval_addr_obj.outputs.opa_results }}

    - name: Evaluate OPA Policy w/addr_group
      id: opa_eval_addr_group
      uses: migara/test-action@master
      with:
        tests: ./validate/opa/panos.rego
        policy: ./examples/files/json/addr_group.json #path to address groups file

    - name: Print Results addr_group
      run: |
       echo $opa_results | jq -r '.result[].expressions[].value'
      env:
       opa_results: ${{ steps.opa_eval_addr_group.outputs.opa_results }}

    - name: Evaluate OPA Policy w/NAT
      id: opa_eval_NAT
      uses: migara/test-action@master
      with:
        tests: ./validate/opa/panos.rego
        policy: ./examples/files/json/nat.json #path to nat security policy file
        
    - name: Print Results nat
      run: |
       echo $opa_results | jq -r '.result[].expressions[].value'
      env:
       opa_results: ${{ steps.opa_eval_NAT.outputs.opa_results }}

    - name: Evaluate OPA Policy w/sec_ex
      id: opa_eval_sec_ex
      uses: migara/test-action@master
      with:
        tests: ./validate/opa/panos.rego
        policy: ./examples/files/json/sec_policy.json #path to security policy file
        
    - name: Print Results sec_ex
      run: |
       echo $opa_results | jq -r '.result[].expressions[].value'
      env:
       opa_results: ${{ steps.opa_eval_sec_ex.outputs.opa_results }}

    - name: Evaluate OPA Policy w/sevices
      id: opa_eval_service
      uses: migara/test-action@master
      with:
        tests: ./validate/opa/panos.rego
        policy: ./examples/files/json/services.json #path to services file
        
    - name: Print Results services
      run: |
       echo $opa_results | jq -r '.result[].expressions[].value'
      env:
       opa_results: ${{ steps.opa_eval_service.outputs.opa_results }}
```
* **validate.yml** : checks to see if JSON validates against the provided schemas (located in the validate folder).
```yaml
name: Validate JSONs

on: [pull_request, push]

jobs:
  verify-json-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1

      - name: Validate tags JSON
        uses: nhalstead/validate-json-action@0.1.3
        with:
          schema: ./validate/schemas/tags_schema.json
          jsons: ./examples/files/json/tags.json #path to tags file
          
      - name: Validate address objects JSON
        uses: nhalstead/validate-json-action@0.1.3
        with:
          schema: ./validate/schemas/addr_obj_schema.json
          jsons: ./examples/files/json/addr_obj.json #path to address objects file

      - name: Validate address group JSON
        uses: nhalstead/validate-json-action@0.1.3
        with:
          schema: ./validate/schemas/addr_group_schema.json
          jsons: ./examples/files/json/addr_group.json #path to address groups file

      - name: Validate nat JSON
        uses: nhalstead/validate-json-action@0.1.3
        with:
          schema: ./validate/schemas/NAT_schema.json
          jsons: ./examples/files/json/nat.json #path to NAT policy file

      - name: Validate security policy JSON
        uses: nhalstead/validate-json-action@0.1.3
        with:
          schema: ./validate/schemas/sec_policy_schema.json
          jsons: ./examples/files/json/sec_policy.json #path to security policy file

      - name: Validate services JSON
        uses: nhalstead/validate-json-action@0.1.3
        with:
          schema: ./validate/schemas/services_schema.json
          jsons: ./examples/files/json/services.json #path to services file
```

3. Create a **"main.tf"** with the panos provider and security profile module blocks.
```terraform
provider "panos" {
  hostname = "<panos_address>"
  username = "<admin_username>"
  password = "<admin_password>"
}

module "policy" {
  source = "sarah-blazic/policy/panos"
  version = "0.1.1"

  #for JSON examples: try(jsondecode(file("<*.json>")), {})
  #for YAML examples: try(yamldecode(file("<*.yaml>")), {})
  tags_file       = try(...decode(file("<tags JSON/YAML>")), {}) # eg. "tags.json"
  services_file   = try(...decode(file("<services JSON/YAML>")), {})
  addr_group_file = try(...decode(file("<address groups JSON/YAML>")), {})
  addr_obj_file   = try(...decode(file("<address objects JSON/YAML>")), {})
  sec_file        = try(...decode(file("<security policies JSON/YAML>")), {})
  nat_file        = try(...decode(file("<NAT policies JSON/YAML>")), {})
}
```

4. Run Terraform
```
terraform init
terraform apply
terraform output -json
```

Cleanup
---
```
terraform destroy
```

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

* each input will create a resource based off of the JSON/YAML file given

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
