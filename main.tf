resource "aws_vpc" "this" {
  count = try(length(var.vpc.cidr_block) > 0, false) ? 1 : 0

  cidr_block                           = var.vpc.cidr_block
  instance_tenancy                     = var.vpc.instance_tenancy
  ipv4_ipam_pool_id                    = var.vpc.ipv4_ipam_pool_id
  ipv4_netmask_length                  = var.vpc.ipv4_netmask_length
  ipv6_cidr_block                      = var.vpc.ipv6_cidr_block
  ipv6_ipam_pool_id                    = var.vpc.ipv6_ipam_pool_id
  ipv6_netmask_length                  = var.vpc.ipv6_netmask_length
  ipv6_cidr_block_network_border_group = var.vpc.ipv6_cidr_block_network_border_group
  enable_dns_support                   = var.vpc.enable_dns_support
  enable_dns_hostnames                 = var.vpc.enable_dns_hostnames
  enable_classiclink                   = var.vpc.enable_classiclink
  enable_classiclink_dns_support       = var.vpc.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block     = var.vpc.assign_generated_ipv6_cidr_block
  tags                                 = merge({ Name = join("/", [local.name, "vpc"]) }, var.vpc.tags, var.tags)
}

# CKV2_AWS_12: "Ensure the default security group of every VPC restricts all traffic"
resource "aws_default_security_group" "this" {
  count = try(length(var.vpc.cidr_block) > 0, false) ? 1 : 0

  vpc_id = aws_vpc.this[0].id
  tags   = merge({ Name = join("/", [local.name, "default"]) }, var.vpc.tags, var.tags)
}

# CKV2_AWS_11: "Ensure VPC flow logging is enabled in all VPCs"
resource "aws_flow_log" "cloudwatch" {
  count = try(length(var.flow_logs.cloudwatch) > 0, false) ? 1 : 0

  log_destination_type = "cloud-watch-logs"
  vpc_id               = aws_vpc.this[0].id

  traffic_type             = var.flow_logs.traffic_type
  iam_role_arn             = var.flow_logs.cloudwatch.iam_role_arn
  log_destination          = var.flow_logs.cloudwatch.log_group_arn
  log_format               = var.flow_logs.log_format
  max_aggregation_interval = var.flow_logs.max_aggregation_interval

  destination_options {
    file_format                = var.flow_logs.destination_options.file_format
    hive_compatible_partitions = var.flow_logs.destination_options.hive_compatible_partitions
    per_hour_partition         = var.flow_logs.destination_options.per_hour_partition
  }

  tags = merge({ Name = join("/", [local.name, "flowlogs", "cloudwatch"]) }, var.vpc.tags, var.tags)
}

# CKV2_AWS_11: "Ensure VPC flow logging is enabled in all VPCs"
resource "aws_flow_log" "s3" {
  count = try(length(var.flow_logs.s3) > 0, false) ? 1 : 0

  log_destination_type = "s3"
  vpc_id               = aws_vpc.this[0].id

  traffic_type             = var.flow_logs.traffic_type
  log_destination          = var.flow_logs.s3.bucket_arn
  log_format               = var.flow_logs.log_format
  max_aggregation_interval = var.flow_logs.max_aggregation_interval

  destination_options {
    file_format                = var.flow_logs.destination_options.file_format
    hive_compatible_partitions = var.flow_logs.destination_options.hive_compatible_partitions
    per_hour_partition         = var.flow_logs.destination_options.per_hour_partition
  }

  tags = merge({ Name = join("/", [local.name, "flowlogs", "s3"]) }, var.vpc.tags, var.tags)
}

# CKV_AWS_130: "Ensure VPC subnets do not assign public IP by default"
resource "aws_subnet" "this" {
  for_each                                       = length(local.subnets_map) > 0 ? local.subnets_map : {}
  assign_ipv6_address_on_creation                = each.value.assign_ipv6_address_on_creation
  availability_zone                              = each.value.availability_zone
  availability_zone_id                           = each.value.availability_zone_id
  cidr_block                                     = each.value.cidr_block
  customer_owned_ipv4_pool                       = each.value.customer_owned_ipv4_pool
  enable_dns64                                   = each.value.enable_dns64
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  ipv6_cidr_block                                = each.value.ipv6_cidr_block
  ipv6_native                                    = each.value.ipv6_native
  map_customer_owned_ip_on_launch                = each.value.map_customer_owned_ip_on_launch
  map_public_ip_on_launch                        = false
  outpost_arn                                    = each.value.outpost_arn
  private_dns_hostname_type_on_launch            = each.value.private_dns_hostname_type_on_launch
  vpc_id                                         = aws_vpc.this[0].id
  tags                                           = merge({ Name = each.value.id }, each.value.tags)
}

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this[0].default_route_table_id

  route = []
  tags  = merge({ Name = join("/", [local.name, "default"]) }, var.vpc.tags, var.tags)
}

resource "aws_route_table" "public" {
  count = length(local.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id
  tags   = merge({ Name = join("/", [local.name, "public"]) }, var.vpc.tags, var.tags)
}

resource "aws_route_table" "private" {
  for_each = length(local.private_subnets) > 0 ? local.private_subnets : {}
  vpc_id   = aws_vpc.this[0].id
  tags     = merge({ Name = join("/", [local.name, "private", each.value.id]) }, var.vpc.tags, var.tags)
}

resource "aws_route_table" "isolated" {
  count = length(local.isolated_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id
  tags   = merge({ Name = join("/", [local.name, "isolated"]) }, var.vpc.tags, var.tags)
}

resource "aws_internet_gateway" "this" {
  count = try(var.vpc.create_internet_gateway == true, false) ? 1 : 0

  vpc_id = aws_vpc.this[0].id
  tags   = merge({ Name = join("/", [local.name, "igw"]) }, var.vpc.tags, var.tags)
}

resource "aws_egress_only_internet_gateway" "this" {
  count = try(var.vpc.create_egress_internet_gateway == true, false) ? 1 : 0

  vpc_id = aws_vpc.this[0].id
  tags   = merge({ Name = join("/", [local.name, "eigw"]) }, var.vpc.tags, var.tags)
}

resource "aws_vpc_dhcp_options" "this" {
  count = try(length(local.dhcp_options) > 0, false) ? 1 : 0

  domain_name          = var.dhcp_options.domain_name
  domain_name_servers  = var.dhcp_options.domain_name_servers
  ntp_servers          = var.dhcp_options.ntp_servers
  netbios_name_servers = var.dhcp_options.netbios_name_servers
  netbios_node_type    = var.dhcp_options.netbios_node_type
  tags                 = var.dhcp_options.tags
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = try(length(local.dhcp_options) > 0, false) ? 1 : 0

  vpc_id          = aws_vpc.this[0].id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}
