locals {
  common_tags = merge(
    map("ManagedBy", "terraform"),
    map("Environment", var.environment),
    map("Product", upper(var.product)),
    map("ProductDomain", upper(var.product_domain)),
  )

  ingresses = flatten([
    for ing in var.ingresses : [
      for rule in ing.rules : {
        self                     = lookup(ing, "self", null) == null ? false : ing["self"]
        source_security_group_id = lookup(ing, "source_security_group_id", null) == null ? null : ing["source_security_group_id"]
        cidr_blocks              = lookup(ing, "cidr_blocks", null) == null ? [] : ing["cidr_blocks"]

        from_port   = tonumber(lookup(var.rules, rule, null) != null ? var.rules[rule][0] : var.rules["_"][0])
        to_port     = tonumber(lookup(var.rules, rule, null) != null ? var.rules[rule][1] : var.rules["_"][1])
        protocol    = lookup(var.rules, rule, null) != null ? var.rules[rule][2] : var.rules["_"][2]
        description = lookup(var.rules, rule, null) != null ? var.rules[rule][3] : var.rules["_"][3]
      } if length(lookup(var.rules, rule, [])) > 1
    ]
  ])

  egresses = flatten([
    for eng in var.egresses : [
      for rule in eng.rules : {
        self                     = lookup(eng, "self", null) == null ? false : eng["self"]
        source_security_group_id = lookup(eng, "source_security_group_id", null) == null ? null : eng["source_security_group_id"]
        cidr_blocks              = lookup(eng, "cidr_blocks", null) == null ? [] : eng["cidr_blocks"]
        prefix_list_ids          = lookup(eng, "prefix_list_ids", null) == null ? [] : eng["prefix_list_ids"]

        from_port   = tonumber(lookup(var.rules, rule, null) != null ? var.rules[rule][0] : var.rules["_"][0])
        to_port     = tonumber(lookup(var.rules, rule, null) != null ? var.rules[rule][1] : var.rules["_"][1])
        protocol    = lookup(var.rules, rule, null) != null ? var.rules[rule][2] : var.rules["_"][2]
        description = lookup(var.rules, rule, null) != null ? var.rules[rule][3] : var.rules["_"][3]
      } if length(lookup(var.rules, rule, [])) > 1
    ]

  ])
}

resource "aws_security_group" "this" {

  tags = merge(
    local.common_tags,
    map("Name", format("%s-%s", var.group_name, var.environment)),
    var.tags
  )

  name        = var.group_name
  vpc_id      = var.vpc_id
  description = var.group_description
}

resource "aws_security_group_rule" "ingress" {
  count = length(local.ingresses) > 0 ? length(local.ingresses) : 0

  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port = local.ingresses[count.index].from_port
  to_port   = local.ingresses[count.index].to_port
  protocol  = local.ingresses[count.index].protocol

  self                     = local.ingresses[count.index].self
  source_security_group_id = local.ingresses[count.index].source_security_group_id
  cidr_blocks              = local.ingresses[count.index].cidr_blocks
}

resource "aws_security_group_rule" "egress" {
  count = length(local.egresses) > 0 ? length(local.egresses) : 0

  type              = "egress"
  security_group_id = aws_security_group.this.id

  from_port = local.egresses[count.index].from_port
  to_port   = local.egresses[count.index].to_port
  protocol  = local.egresses[count.index].protocol

  self                     = local.egresses[count.index].self
  source_security_group_id = local.egresses[count.index].source_security_group_id
  cidr_blocks              = local.egresses[count.index].cidr_blocks
  prefix_list_ids          = lookup(local.egresses[count.index], "prefix_list_ids", [])
}
