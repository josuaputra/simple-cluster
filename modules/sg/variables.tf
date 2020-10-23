variable "module_depends_on" {
  type    = any
  default = null
}

variable environment {
  description = "Environment Information"
  type        = string
}

variable product {
  description = "Product unit the resource belongs to"
  type        = string
}

variable product_domain {
  description = "Product domain the resource belongs to"
  type        = string
}

variable "tags" {
  description = "A mapping tags to be added into all resources in this modules"
  type        = map
  default     = {}
}

variable "vpc_id" {
  description = "Selected AWS VPC id for the security groups"
  type        = string
}

variable "group_name" {
  description = "Security group name"
  type        = string
}

variable "group_description" {
  description = "Security group description"
  type        = string
}

variable "ingresses" {
  description = "List of ingresses rules to be added into security groups"
  type = list(
    object({
      self = bool
      source_security_group_id = string
      cidr_blocks = list(string)

      rules = list(string)
    })
  )

  default = [
    {
      self = true
      source_security_group_id = null
      cidr_blocks = null

      rules = [
        "all"
      ]

    }
  ]
}

variable "egresses" {
  description = "List of egresses rules to be added into security groups"
  type = list(
    object({
      self = bool
      source_security_group_id = string
      prefix_list_ids = list(string)
      cidr_blocks = list(string)

      rules = list(string)
    })
  )

  default = [
    {
      self = null
      source_security_group_id = null
      prefix_list_ids = null
      cidr_blocks = [
        "0.0.0.0/0"
      ]

      rules = [
        "all"
      ]

    }
  ]
}
