variable "name" {
  description = "(Optional) The base name of the VPC and its resources."
  type        = string
  default     = ""
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource."
  type        = map(any)
  default     = {}
}

variable "vpc" {
  description = "(Optional) Object containing the VPC configuration."
  type = object({
    cidr_block                           = optional(string)
    instance_tenancy                     = optional(string)
    ipv4_ipam_pool_id                    = optional(string)
    ipv4_netmask_length                  = optional(string)
    ipv6_cidr_block                      = optional(string)
    ipv6_ipam_pool_id                    = optional(string)
    ipv6_netmask_length                  = optional(string)
    ipv6_cidr_block_network_border_group = optional(string)
    enable_dns_support                   = optional(bool)
    enable_dns_hostnames                 = optional(bool)
    enable_classiclink                   = optional(bool)
    enable_classiclink_dns_support       = optional(bool)
    assign_generated_ipv6_cidr_block     = optional(bool)
    create_internet_gateway              = optional(bool)
    create_egress_internet_gateway       = optional(bool)
    tags                                 = optional(map(string))
  })
  default = {}
}

variable "flow_logs" {
  description = "(Optional) Object containing the configuration for VPC Flow Logs."
  type = object({
    traffic_type             = optional(string)
    log_format               = optional(string)
    max_aggregation_interval = optional(number)
    tags                     = optional(map(string))

    cloudwatch = optional(object({
      iam_role_arn  = optional(string)
      log_group_arn = optional(string)
    }))

    s3 = optional(object({
      bucket_arn = optional(string)
    }))

    destination_options = optional(object({
      file_format                = optional(string)
      hive_compatible_partitions = optional(bool)
      per_hour_partition         = optional(bool)
    }))
  })
  default = {}
}

variable "subnets" {
  description = "(Optional) Object containing the configuration for VPC Subnets."
  type = map(list(object({
    assign_ipv6_address_on_creation                = optional(bool)
    availability_zone                              = optional(string)
    availability_zone_id                           = optional(string)
    cidr_block                                     = optional(string)
    customer_owned_ipv4_pool                       = optional(string)
    enable_dns64                                   = optional(bool)
    enable_resource_name_dns_aaaa_record_on_launch = optional(bool)
    enable_resource_name_dns_a_record_on_launch    = optional(bool)
    ipv6_cidr_block                                = optional(string)
    ipv6_native                                    = optional(bool)
    map_customer_owned_ip_on_launch                = optional(string)
    map_public_ip_on_launch                        = optional(bool)
    outpost_arn                                    = optional(string)
    private_dns_hostname_type_on_launch            = optional(string)
    tags                                           = optional(map(string))
  })))
  default = {}
}

variable "dhcp_options" {
  description = "(Optional) Object containing the configuration for DHCP Options."
  type = object({
    domain_name          = optional(string)
    domain_name_servers  = optional(list(string))
    ntp_servers          = optional(list(string))
    netbios_name_servers = optional(list(string))
    netbios_node_type    = optional(number)
    tags                 = optional(map(string))
  })
  default = {}
}