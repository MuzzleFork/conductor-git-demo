locals {
  name = try(length(var.name) > 0, false) ? "${var.name}" : ""

  subnets = flatten([
    for resource in keys(var.subnets) : [
      for subnet in var.subnets[resource] : {
        id                                             = try(length(subnet.availability_zone) > 0, false) ? "${resource}/${subnet.availability_zone}" : "${resource}/${subnet.availability_zone_id}"
        assign_ipv6_address_on_creation                = subnet.assign_ipv6_address_on_creation
        availability_zone                              = subnet.availability_zone
        availability_zone_id                           = subnet.availability_zone_id
        cidr_block                                     = subnet.cidr_block
        customer_owned_ipv4_pool                       = subnet.customer_owned_ipv4_pool
        enable_dns64                                   = subnet.enable_dns64
        enable_resource_name_dns_aaaa_record_on_launch = subnet.enable_resource_name_dns_aaaa_record_on_launch
        enable_resource_name_dns_a_record_on_launch    = subnet.enable_resource_name_dns_a_record_on_launch
        ipv6_cidr_block                                = subnet.ipv6_cidr_block
        ipv6_native                                    = subnet.ipv6_native
        map_customer_owned_ip_on_launch                = subnet.map_customer_owned_ip_on_launch
        outpost_arn                                    = subnet.outpost_arn
        private_dns_hostname_type_on_launch            = subnet.private_dns_hostname_type_on_launch
        tags                                           = subnet.tags
      }
    ]
  ])

  subnets_map = {
    for subnet in local.subnets : subnet.id => subnet
  }

  public_subnets = {
    for subnet in local.subnets : subnet.id => subnet
    if length(regexall("^public/", subnet.id)) > 0 ? true : false
  }

  private_subnets = {
    for subnet in local.subnets : subnet.id => subnet
    if length(regexall("^private/", subnet.id)) > 0 ? true : false
  }

  isolated_subnets = {
    for subnet in local.subnets : subnet.id => subnet
    if length(regexall("^isolated/", subnet.id)) > 0 ? true : false
  }

  dhcp_options = try(concat(
    try(formatlist(var.dhcp_options.domain_name_servers), []),
    try(formatlist(var.dhcp_options.ntp_servers), []),
    try(formatlist(var.dhcp_options.netbios_name_servers), [])
  ), [])
}