terraform {
  required_version = "~> 0.12.0"
}

locals {

  common_tags = merge(
    var.tags,
    map("ManagedBy", "terraform"),
    map("Environment", var.environment),
    map("Product", upper(var.product)),
    map("ProductDomain", upper(var.product_domain)),
  )

}

data "aws_availability_zones" "available" {
  state = "available"
}

# Provision VPC resource
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    var.vpc_additional_tags,
    map("Name", lower(format("%s-vpc", var.name))),
  )

}

# Provision public subnet resources
# Subnet for dmz-tier services, for e.g VPN, public-bastion
resource "aws_subnet" "public" {
  count = var.default_network ? length(data.aws_availability_zones.available.names) : 0

  tags = merge(
    local.common_tags,
    var.public_subnet_additional_tags,
    map("Name", lower(format("%s-public-subnet", var.name))),
    map("Tier", "public"),
  )

  vpc_id            = aws_vpc.this.id
  availability_zone = element(data.aws_availability_zones.available.names[*], count.index)

  # start from 172.x.0.0/20 - 172.x.32.0/20
  cidr_block = cidrsubnet(var.vpc_cidr_block, 4, count.index)
}

# Provision middleware private-subnet resources
# Subnet for middleware-tier services, for e.g RDS, Elasticache, Redshift, etc.
resource "aws_subnet" "middleware" {
  count = var.default_network ? length(data.aws_availability_zones.available.names) : 0

  tags = merge(
    local.common_tags,
    var.middleware_subnet_additional_tags,
    map("Name", lower(format("%s-middleware-subnet", var.name))),
    map("Tier", "middleware"),
  )

  vpc_id            = aws_vpc.this.id
  availability_zone = element(data.aws_availability_zones.available.names[*], count.index)

  # start from 172.x.48.0/20 - 172.x.80.0/20
  cidr_block = cidrsubnet(var.vpc_cidr_block, 4, count.index + 3)
}

# Provision application private-subnet resources
# Subnet for app-tier services, for e.g microservices, etc.
resource "aws_subnet" "app" {
  count = var.default_network ? length(data.aws_availability_zones.available.names) : 0

  tags = merge(
    local.common_tags,
    var.app_subnet_additional_tags,
    map("Name", lower(format("%s-app-subnet", var.name))),
    map("Tier", "application"),
  )

  vpc_id            = aws_vpc.this.id
  availability_zone = element(data.aws_availability_zones.available.names[*], count.index)

  # start from 172.x.96.0/19 - 172.x.160.0/19
  cidr_block = cidrsubnet(var.vpc_cidr_block, 3, count.index + 3)
}

# Provision general private-subnet resources
# Subnet for general-tier services, for e.g self-managed/in-house services
resource "aws_subnet" "general" {
  count = var.default_network ? length(data.aws_availability_zones.available.names) : 0

  tags = merge(
    local.common_tags,
    var.general_subnet_additional_tags,
    map("Name", lower(format("%s-general-subnet", var.name))),
    map("Tier", "general"),
  )

  vpc_id            = aws_vpc.this.id
  availability_zone = element(data.aws_availability_zones.available.names[*], count.index)

  # start from 172.x.192.0/20 - 172.x.224.0/20
  cidr_block = cidrsubnet(var.vpc_cidr_block, 4, count.index + 12)
}

# Provision intra subnet resources
# Subnet for intra-tier services, for any service that no need internet-access
resource "aws_subnet" "intra" {
  count = var.default_network ? length(data.aws_availability_zones.available.names) : 0

  tags = merge(
    local.common_tags,
    var.intra_subnet_additional_tags,
    map("Name", lower(format("%s-intra-subnet", var.name))),
    map("Tier", "intranet"),
  )

  vpc_id            = aws_vpc.this.id
  availability_zone = element(data.aws_availability_zones.available.names[*], count.index)

  # start from 172.x.240.0/22 - 172.x.248.0/22
  cidr_block = cidrsubnet(var.vpc_cidr_block, 6, count.index + 60)
}

# Provision RDS subnet groups
# RDS subnet groups associated with middleware private-subnet
resource "aws_db_subnet_group" "this" {
  count = var.default_network && var.enable_rds_subnet_group ? 1 : 0

  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-default-rds-subnet-group", var.name))),
    map("Tier", "middleware"),
  )

  name       = lower(format("%s-default-rds-subnet-group", var.name))
  subnet_ids = aws_subnet.middleware[*].id

  lifecycle {
    ignore_changes = [
      id
    ]
  }
}

# Provision Elasticache subnet groups
# Elasticache subnet groups associated with middleware private-subnet
resource "aws_elasticache_subnet_group" "this" {
  count = var.default_network && var.enable_elasticache_subnet_group ? 1 : 0

  name       = lower(format("%s-default-elasticache-subnet-group", var.name))
  subnet_ids = aws_subnet.middleware[*].id

  lifecycle {
    ignore_changes = [
      id
    ]
  }
}

# Provision Redshift subnet groups
# Redshift subnet groups associated with middleware private-subnet
resource "aws_redshift_subnet_group" "this" {
  count = var.default_network && var.enable_redshift_subnet_group ? 1 : 0

  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-default-redshift-subnet-group", var.name))),
    map("Tier", "middleware"),
  )

  name       = lower(format("%s-default-redshift-subnet-group", var.name))
  subnet_ids = aws_subnet.middleware[*].id

  lifecycle {
    ignore_changes = [
      id
    ]
  }
}

# Provision Internet gateway as a public gateway for VPC
resource "aws_internet_gateway" "this" {
  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-igw", var.name))),
    map("Tier", "internet-gateway"),
  )

  vpc_id = aws_vpc.this.id
}

# Provision Elastic IPs for NAT gateway
resource "aws_eip" "nat" {
  count = var.default_network ? length(data.aws_availability_zones.available.names) : 0

  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-natgw-eip", var.name))),
    map("Tier", "nat-gateway"),
  )

  vpc = true
}

# Provision NAT gateway for internet-access from instances
resource "aws_nat_gateway" "this" {
  depends_on = [
    aws_internet_gateway.this,
    aws_eip.nat
  ]

  count = var.default_network ? length(data.aws_availability_zones.available.names) : 0

  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-natgw", var.name))),
    map("Tier", "nat-gateway"),
  )

  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
}

# -----------------
# Public route table
# -----------------

# Provision public route table for internet-facing
resource "aws_route_table" "public" {
  count = var.default_network ? 1 : 0

  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-public-routetable", var.name))),
    map("Tier", "public"),
  )

  vpc_id = aws_vpc.this.id
}

resource "aws_route" "public" {
  count                  = var.default_network ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Provision public route table association
resource "aws_route_table_association" "public" {
  count = var.default_network ? length(aws_subnet.public[*].id) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# -----------------
# Middleware route table
# -----------------

# Provision middleware route table for internet-access
resource "aws_route_table" "middleware" {
  count = var.default_network ? length(aws_nat_gateway.this) : 0

  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-middleware-routetable", var.name))),
    map("Tier", "middleware"),
  )

  vpc_id = aws_vpc.this.id
}

resource "aws_route" "middleware" {
  count = var.default_network ? length(aws_nat_gateway.this) : 0

  route_table_id         = element(aws_route_table.middleware[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)
}

# Provision middleware route table association
resource "aws_route_table_association" "middleware" {
  count = var.default_network ? length(aws_subnet.middleware[*].id) : 0

  subnet_id      = element(aws_subnet.middleware[*].id, count.index)
  route_table_id = element(aws_route_table.middleware[*].id, count.index)
}


# -----------------
# Application route table
# -----------------

# Provision application route table for internet-access
resource "aws_route_table" "app" {
  count = var.default_network ? length(aws_nat_gateway.this) : 0

  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-app-routetable", var.name))),
    map("Tier", "application"),
  )

  vpc_id = aws_vpc.this.id
}

resource "aws_route" "app" {
  count = var.default_network ? length(aws_nat_gateway.this) : 0

  route_table_id         = element(aws_route_table.app[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)
}

# Provision application route table association
resource "aws_route_table_association" "app" {
  count = var.default_network ? length(aws_subnet.app[*].id) : 0

  subnet_id      = element(aws_subnet.app[*].id, count.index)
  route_table_id = element(aws_route_table.app[*].id, count.index)
}

# -----------------
# general route table
# -----------------

# Provision general route table for internet-access
resource "aws_route_table" "general" {
  count = var.default_network ? length(aws_nat_gateway.this) : 0

  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-general-routetable", var.name))),
    map("Tier", "general"),
  )

  vpc_id = aws_vpc.this.id
}

resource "aws_route" "general" {
  count = var.default_network ? length(aws_nat_gateway.this) : 0

  route_table_id         = element(aws_route_table.general[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)
}

# Provision general route table for internet-access
resource "aws_route_table_association" "general" {
  count = var.default_network ? length(aws_subnet.general[*].id) : 0

  subnet_id      = element(aws_subnet.general[*].id, count.index)
  route_table_id = element(aws_route_table.general[*].id, count.index)
}

# -----------------
# Intra route table
# -----------------

# Provision intra route table
resource "aws_route_table" "intra" {
  count = var.default_network ? 1 : 0

  tags = merge(
    local.common_tags,
    map("Name", lower(format("%s-intra-routetable", var.name))),
    map("Tier", "intranet"),
  )

  vpc_id = aws_vpc.this.id
}

# Provision intra route table
resource "aws_route_table_association" "intra" {
  count = var.default_network ? length(aws_subnet.intra[*].id) : 0

  subnet_id      = element(aws_subnet.intra[*].id, count.index)
  route_table_id = aws_route_table.intra[0].id
}
