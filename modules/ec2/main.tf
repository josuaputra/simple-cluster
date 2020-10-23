terraform {
  required_version = "~> 0.12.0"
}

locals {
  is_t_instance_type = replace(var.instance_type, "/^t(2|3|3a){1}\\..*$/", "1") == "1" ? true : false

  common_tags = merge(
    map("ManagedBy", "terraform"),
    map("Environment", var.environment),
    map("Product", upper(var.product)),
    map("ProductDomain", upper(var.product_domain)),
    map("ServiceName", var.service_name),
  )

  default_root_block_device = merge(
    map("delete_on_termination", true),
    map("encrypted", false),
    map("volume_size", 15),
    map("volume_type", "gp2")
  )
}

# Get Subnet IDs by Tier tag
data "aws_subnet_ids" "this" {
  count = length(var.subnet_ids) > 0 ? 0 : 1

  vpc_id = var.vpc_id == "" ? null : var.vpc_id

  filter {
    name = "tag:Tier"
    values = [
      var.tier
    ]
  }
}

# Get Security Group IDS by Group Name
data "aws_security_groups" "this" {
  count = length(var.vpc_security_group_names) > 0 ? 1 : 0

  filter {
    name = "group-name"
    values = var.vpc_security_group_names
  }

  filter {
    name = "vpc-id"
    values = [
      var.vpc_id
    ]
  }
}

resource "aws_instance" "this" {
  count = var.instance_count

  tags = merge(
    local.common_tags,
    map("Name", var.instance_count > 1 && var.use_suffix ? format("%s-%s-%s", var.name, var.environment, count.index) : format("%s-%s", var.name, var.environment)),
    var.tags
  )

  volume_tags = merge(
    local.common_tags,
    map("Name", var.instance_count > 1 && var.use_suffix ? format("%s-%s-%s", var.name, var.environment, count.index) : format("%s-%s", var.name, var.environment)),
    var.volume_tags
  )

  ami                  = var.instance_ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  monitoring           = var.monitoring
  iam_instance_profile = var.iam_instance_profile

  disable_api_termination = var.termination_protection

  # Network Specification
  subnet_id              = element(coalescelist(var.subnet_ids, length(data.aws_subnet_ids.this) > 0 ? data.aws_subnet_ids.this[0].ids[*] : []), count.index)
  vpc_security_group_ids = length(data.aws_security_groups.this) > 0 ? data.aws_security_groups.this[0].ids : var.vpc_security_group_ids
  private_ip             = length(var.private_ips) > 0 ? element(var.private_ips, count.index) : null

  # Attention! We strongly encourage EC2 instance to not attched with public ip
  # Attach EC2 instances with public ip address and only works with public tier subnet
  associate_public_ip_address = var.associate_public_ip_address

  # Block device mapping
  ebs_optimized = var.ebs_optimized

  root_block_device {
    delete_on_termination = lookup(merge(local.default_root_block_device, var.root_block_device), "delete_on_termination", null)
    encrypted             = lookup(merge(local.default_root_block_device, var.root_block_device), "encrypted", null)
    iops                  = lookup(merge(local.default_root_block_device, var.root_block_device), "iops", null)
    kms_key_id            = lookup(merge(local.default_root_block_device, var.root_block_device), "kms_key_id", null)
    volume_size           = lookup(merge(local.default_root_block_device, var.root_block_device), "volume_size", null)
    volume_type           = lookup(merge(local.default_root_block_device, var.root_block_device), "volume_type", null)
  }

  # Credit CPU specification for `t` instance type
  credit_specification {
    cpu_credits = local.is_t_instance_type ? var.cpu_credits : null
  }
}