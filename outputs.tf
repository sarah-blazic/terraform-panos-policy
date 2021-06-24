////#outputs
//output "rules" {
////  value = {for _ , policy in local.sec_pol_f.rules : policy.name => policy}
////  value = local.sec_pol_f
////  value = flatten([
////    for k, v in local.sec_pol_f : flatten( {
////    for rule, rulesin v : {
////    rules = rules
////    }
////    })
////    ])
////  value = { for policy in each.value.rules : policy.name => policy }
////
////      value = flatten([
////      for policy, hi in local.sec_pol_f : [
////        for name, property in hi : [
////         // merge({ "property" = property }, { "name" = name } ,{"policy" = policy})
////          zipmap(
////            [name],[property]
////          )
////        ]
////      ]
////    ])
//}


// output "look" {
//   value = flatten([
//    for dg, rule_bases in yamldecode(file("./firewall_rules.yml")).security_policy_rules : [
//      for rulebase, rules in rule_bases : [
//        merge({ "rules" = rules }, { "device_group" = dg }, { "rulebase" = rulebase })
//      ]
//    ]
//  ])
//   //value = yamldecode(file("./firewall_rules.yml")).security_policy_rules
// }



