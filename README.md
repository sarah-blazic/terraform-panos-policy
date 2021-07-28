Palo Alto Networks Panorama Policy Module for Policy as Code
---
This Terraform module allows users to configure policies (NAT and Security Policies) along with tags, address objects, address groups, and services with Palo Alto Networks **PAN-OS** based PA-Series devices.

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
  version = "0.1.3"

  #for JSON examples: try(jsondecode(file("<*.json>")), {})
  #for YAML examples: try(yamldecode(file("<*.yaml>")), {})
  tags       = try(...decode(file("<tags JSON/YAML>")), {}) # eg. "tags.json"
  services   = try(...decode(file("<services JSON/YAML>")), {})
  addr_group = try(...decode(file("<address groups JSON/YAML>")), {})
  addr_obj   = try(...decode(file("<address objects JSON/YAML>")), {})
  sec        = try(...decode(file("<security policies JSON/YAML>")), {})
  nat        = try(...decode(file("<NAT policies JSON/YAML>")), {})
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

Inputs
---
Name | Description | Type | Default | Required
-----|-----|-----|-----|-----
tags | (optional) List of tag objects.<br><br>- `name`: (required) The administrative tag's name.<br>- `device_group`: (optional) The device group location (default: `shared`).<br>- `comment`: (optional) The description of the administrataive tag.<br>- `color`: (optional) The tag's color. This should either be an empty string (no color) or a string such as `color1`. Note that the colors go from 1 to 16.<br><br>Example:<pre><br>[<br>  {<br>        name = "trust"<br>  }<br>  {<br>        name = "untrust"<br>        comment = "for untrusted zones"<br>        color = "color4"<br>  }<br>  {<br>        name = "AWS"<br>        device_group = "AWS"<br>        color = "color8"<br>  }<br>]</pre> |`any`|n/a|yes
services | (optional) List of service objects.<br><br>- `name`: (required) The service object's name.<br>- `device_group`: (optional) The device group location (default: `shared`).<br>- `description`: (optional) The description of the service object.<br>- `protocol`: (required) The service's protocol. Valid values are `tcp`, `udp`, or `sctp` (only for PAN-OS 8.1+).<br>- `source_port`: (optional) The source port. This can be a single port number, range (1-65535), or comma separated (80,8080,443).<br>- `destination_port`: (required) The destination port. This can be a single port number, range (1-65535), or comma separated (80,8080,443).<br>- `tags`: (optional) List of administrative tags.<br>- `override_session_timeout`: (optional) Boolean to override the default application timeouts (default: `false`). Only available for PAN-OS 8.1+.<br>- `override_timeout`: (optional) Integer for the overridden timeout if TCP protocol selected. Only available for PAN-OS 8.1+.<br>- `override_half_closed_timeout`: (optional) Integer for the overridden half closed timeout if TCP protocol selected. Only available for PAN-OS 8.1+.<br>- `override_time_wait_timeout`: (optional) Integer for the overridden wait time if TCP protocol selected. Only available for PAN-OS 8.1+.<br><br>Example:<pre><br>[<br>    {<br>      name = "service1"<br>      protocol = "tcp"<br>      destination_port = "8080"<br>      source_port = "400"<br>      override_session_timeout = true<br>      override_timeout = 250<br>      override_time_wait_timeout = 590<br>    }<br>    {<br>      name = "service2"<br>      protocol = "udp"<br>      destination_port = "80"<br>    }<br>]</pre> | `any` | n/a | yes
addr_obj | (optional) List of the address objects.<br><br>- `name`: (required) The address object's name.<br>- `device_group`: (optional) The device group location (default: `shared`).<br>- `description`: (optional) The description of the address object.<br>- `type`: (optional) The type of address object. Valid values are `ip-netmask`, `ip-range`, `fqdn`, or `ip-wildcard` (only available with PAN-OS 9.0+) (default: `ip-netmask`).<br>- `value`: (required) The address object's value. This can take various forms depending on what type of address object this is, but can be something like `192.168.80.150` or `192.168.80.0/24`.<br>- `tags`: (optional) List of administrative tags.<br><br>Example:<pre><br>[<br>    {<br>      name = "azure_int_lb_priv_ip"<br>      type = "ip-netmask"<br>      value = {<br>            "ip-netmask = "10.100.4.40/32"<br>      }<br>      tags = ["trust"]<br>      device_group = "AZURE"<br>    }<br>    {<br>      name = "pa_updates"<br>      type = "fqdn"<br>      value = {<br>            fqdn = "updates.paloaltonetworks.com"<br>      }<br>      description = "palo alto updates"<br>    }<br>    {<br>      name = "ntp1"<br>      type = "ip-range"<br>      value = {<br>            ip-range = "10.0.0.2-10.0.0.10"<br>      }<br>    }<br>]</pre>|`any`|n/a|yes
addr_group | (optional) List of the address group objects.<br><br>- `name`: (required) The address group's name.<br>- `device_group`: (optional) The device group location (default: `shared`).<br>- `description`: (optional) The description of the address group.<br>- `static_addresses`: (optional) The address objects to include in this statically defined address group.<br>- `dynamic_match`: (optional) The IP tags to include in this DAG. Inputs are structured as follows `'<tag name>' and ...` or `'<tag name>' or ...`.<br>- `tags`: (optional) List of administrative tags.<br><br>Example:<pre><br>[<br>    {<br>      name = "static ntp grp"<br>      description": "ntp servers"<br>      static_addresses = ["ntp1", "ntp2"]<br>    }<br>    {<br>      name = "trust and internal grp",<br>      description = "dynamic servers",<br>      dynamic_match = "'trust'and'internal'",<br>      tags = ["trust"]<br>    }<br>]</pre>|`any`|n/a|yes
sec_policy | (optional) List of the Security policy rule objects.<br><br>- `device_group`: (optional) The device group location (default: `shared`).<br>- `rulebase`: (optional) The rulebase for the Security Policy. Valid values are `pre-rulebase` and `post-rulebase` (default: `pre-rulebase`).<br>- `position_keyword`: (optional) A positioning keyword for this group. Valid values are `before`, `directly before`, `after`, `directly after`, `top`, `bottom`, or left empty to have no particular placement (default: empty). This parameter works in combination with the `position_reference` parameter.<br>- `position_reference`: (optional) Required if `position_keyword` is one of the "above" or "below" variants, this is the name of a non-group rule to use as a reference to place this group.<br>- `rules`: (optional) The security rule definition. The security rule ordering will match how they appear in the terraform plan file.<ul>- `name`: (required) The security rule's name.<br>- `description`: (optional) The description of the security rule.<br>- `type`: (optional) Rule type. Valid values are `universal`, `interzone`, or `intrazone` (default: `universal`).<br>- `tags`: (optional) List of administrative tags.<br>- `source_zones`: (optional) List of source zones (default: `any`).<br>- `negate_source`: (optional) Boolean designating if the source should be negated (default: `false`).<br>- `source_users`: (optional) List of source users (default: `any`).<br>- `hip_profiles`: (optional) List of HIP profiles (default: `any`).<br>- `destination_zones`: (optional) List of destination zones (default: `any`).<br>- `destination_addresses`: (optional) List of destination addresses (default: `any`).<br>- `negate_destination`: (optional) Boolean designating if the destination should be negated (default: `false`).<br>- `applications`: (optional) List of applications (default: `any`).<br>- `services`: (optional) List of services (default: `application-default`).<br>- `category`: (optional) List of categories (default: `any`).<br>- `action`: (optional) Action for the matched traffic. Valid values are `allow`, `drop`, `reset-client`, `reset-server`, or `reset-both` (default: `allow`).<br>- `log_setting`: (optional) Log forwarding profile.<br>- `log_start`: (optional) Boolean designating if log the start of the traffic flow (default: `false`).<br>- `log_end`: (optional) Boolean designating if log the end of the traffic flow (default: `true`).<br>- `disabled`: (optional) Boolean designating if the security policy rule is disabled (default: `false`).<br>- `schedule`: (optional) The security rule schedule.<br>- `icmp_unreachable`: (optional) Boolean enabling ICMP unreachable (default: `false`).<br>- `disable_server_response_inspection`: (optional) Boolean disabling server response inspection (default: `false`).<br>-`profile_setting`: (optional) The profile setting. Valid values are `none`, `group`, or `profiles` (default: `none`).<br>- `group`: (optional) Profile setting: `Group` - The group profile name.<br>- `virus`: (optional) Profile setting: `Profiles` - Input the desired antivirus profile name.<br>- `spyware`: (optional) Profile setting: `Profiles` - Input the desired anti-spyware profile name.<br>- `vulnerability`: (optional) Profile setting: `Profiles` - Input the desired vulnerability profile name.<br>- `url_filtering`: (optional) Profile setting: `Profiles` - Input the desired URL filtering profile name.<br>- `file_blocking`: (optional) Profile setting: `Profiles` - Input the desired File-Blocking profile name.<br>- `wildfire_analysis`: (optional) Profile setting: `Profiles` - Input the desired Wildfire Analysis profile name.<br>- `data_filtering`: (optional) Profile setting: `Profiles` - Input the desired Data Filtering profile name.</ul><br><br>Example:<pre><br>[<br>    {<br>      rulebase = "pre-rulebase"<br>      rules = [<br>            {<br>              name = "Outbound Block Rule"<br>              description = "Block outbound sessions with destination address matching one of the Palo Alto Networks external dynamic lists for high risk and known malicious IP addresses."<br>              source_zones = ["any"]<br>              source_addresses = ["any"]<br>              destination_zones = ["any"]<br>              destination_addresses = [<br>                    "panw-highrisk-ip-list",<br>                    "panw-known-ip-list",<br>                    "panw-bulletproof-ip-list"<br>              ]<br>              action = "deny"<br>            }<br>      ]<br>    }<br>]</pre>|`any`|n/a|yes
nat_policy | (optional) List of the NAT policy rule objects.<br><br><br>- `device_group`: (optional) The device group location (default: `shared`).<br>- `rulebase`: (optional) The rulebase for the NAT Policy. Valid values are `pre-rulebase` and `post-rulebase` (default: `pre-rulebase`).<br>- `position_keyword`: (optional) A positioning keyword for this group. Valid values are `before`, `directly before`, `after`, `directly after`, `top`, `bottom`, or left empty to have no particular placement (default: empty). This parameter works in combination with the `position_reference` parameter.<br>- `position_reference`: (optional) Required if `position_keyword` is one of the "above" or "below" variants, this is the name of a non-group rule to use as a reference to place this group.<br>- `rules`: (optional) The NAT rule definition. The NAT rule ordering will match how they appear in the terraform plan file.<ul>- `name`: (required) The NAT rule's name.<br>- `description`: (optional) The description of the NAT rule.<br>- `type`: (optional) NAT type. Valid values are `ipv4`, `nat64`, or `nptv6` (default: `ipv4`).<br>- `tags`: (optional) List of administrative tags.<br>- `disabled`: (optional) Boolean designating if the security policy rule is disabled (default: `false`).<br><br><br>- `original_packet`: (required) The original packet specification.<ul>- `source_zones`: (optional) List of source zones (default: `any`).<br>- `destination_zone`: (optional) The destination zone (default: `any`).<br>- `destination_interface`: (optional) Egress interface from the lookup (default: `any`).<br>- `service`: (optional) Service for the original packet (default: `any`).<br>- `source_addresses`: (optional) List of source addresses (default: `any`).<br>- `destination_addresses`: (optional) List of destination addresses (default: `any`).</ul><br><br>- `translated_packet`: (required) The translated packet specifications.<ul>- `source`: (optional) The source specification. Valid values are `none`, `dynamic_ip_port`, `dynamic_ip`, or `static_ip` (default: `none`).<ul><br>- `dynamic_ip_and_port`: (optional) Dynamic IP and port source translation specification.<ul>- `translated_addresses`: (optional) Not functional if `interface_address` is configured. List of translated addresses.</ul><ul>- `interface_address`: (optional) Not functional if `translated_addresses` is configured. Interface address source translation type specifications.<ul>- `interface`: (required) The interface.<br>- `ip_address`: (optional) The IP address.</ul></ul><br>- `dynamic_ip`: (optional) Dynamic IP source translation specification.<ul>- `translated_addresses`: (optional) The list of translated addresses.<br>- `fallback`: (optional) The fallback specifications (default: `none`).<ul>- `translated_addresses`: (optional) Not functional if `interface_address` is configured. List of translated addresses.<br>- `interface_address`: (optional) Not functional if `translated address` is configured. The interface address fallback specifications.<ul>- `interface`: (required) Source address translated fallback interface.<br>- `type`: (optional) Type of interface fallback. Valid values are `ip` or `floating` (default: `ip`).<br>- `ip_address`: (optional) IP address of the fallback interface.</ul></ul></ul><br>- `static_ip`: (optional) Static IP source translation specifications.<ul>- `translated_address`: (required) The statically translated source address.<br>- `bi_directional`: (optional) Boolean enabling bi-directional source address translation (default: `false`).</ul></ul><br>- `destination`: (optional) The destination specification. Valid values are `none`, `static_translation`, or `dynamic_translation` (default: `none`).<ul><br>- `static_translation`: (optional) Specifies a static destination NAT.<ul>- `address`: (required) Destination address translation address.<br>- `port`: (optional) Integer destination address translation port number.</ul><br>- `dynamic_translation`: (optional) Specify a dynamic destination NAT. Only available for PAN-OS 8.1+.<ul>- `address`: (required) Destination address translation address.<br>- `port`: (optional) Integer destination address translation port number.<br>- `distribution`: (optional) Distribution algorithm for destination address pool. Valid values are `round-robin`, `source-ip-hash`, `ip-modulo`, `ip-hash`, or `least-sessions` (default: `round-robin`). Only available for PAN-OS 8.1+.</ul></ul></ul></ul><br><br>Example:<pre><br>[<br>    {<br>      device_group = "AWS"<br>      rules = [<br>            {<br>              name = "rule1"<br>              original_packet = {<br>                    source_zones = ["trust"]<br>                    destination_zone = "untrust"<br>                    destination_interface = "any"<br>                    source_addresses = ["google_dns1"]<br>                    destination_addresses = ["any"]<br>              }<br>              translated_packet = {<br>                    source = "dynamic_ip"<br>                    translated_addresses = ["google_dns1", "google_dns2"]<br>                    destination = "static_translation"<br>                    static_translation = {<br>                      address = "10.2.3.1"<br>                      port = 5678<br>                    }<br>              }<br>            }<br>            {<br>              name = "rule2"<br>              original_packet = {<br>                    source_zones = ["untrust"]<br>                    destination_zone = "trust"<br>                    destination_interface = "any"<br>                    source_addresses = ["any"]<br>                    destination_addresses = ["any"]<br>              }<br>              translated_packet = {<br>                    source = "static_ip<br>                    static_ip = {<br>                      translated_address = "192.168.1.5"<br>                      bi_directional = true<br>                    }<br>                    destination = "none"<br>              }<br>            }<br>            {<br>                name = "rule3"<br>                original_packet = {<br>                  source_zones = ["dmz"]<br>                  destination_zone = "dmz"<br>                  destination_interface = "any"<br>                  source_addresses = ["any"]<br>                  destination_addresses = ["any"]<br>                }<br>                translated_packet = {<br>                  source = "dynamic_ip_and_port"<br>                  interface_address = {<br>                    interface = "ethernet1/5"<br>                  }<br>                  destination = "none"<br>                }<br>            }<br>            {<br>              name = "rule4"<br>              original_packet = {<br>                    source_zones = ["dmz"]<br>                    destination_zone = "dmz"<br>                    destination_interface = "any"<br>                    source_addresses = ["any"]<br>                    destination_addresses = ["trust and internal grp"]<br>              }<br>              translated_packet = {<br>                    source = "dynamic_ip"<br>                    translated_addresses = ["localnet"]<br>                    fallback = {<br>                      translated_addresses = ["ntp1"]<br>                    }<br>                    destination = "dynamic_translation"<br>                    dynamic_translation = {<br>                      address = "localnet"<br>                      port = 1234<br>                    }<br>              }<br>            }<br>      ]<br>    }<br>]</pre>|`any`|n/a|yes

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
