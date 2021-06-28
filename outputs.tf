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

#module outputs
//output "created_tags" {
//  value = module.tags_mod.created_tags
//}
//
//output "created_services" {
//  value = module.services_mod.created_services
//}
