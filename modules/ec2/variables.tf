variable "module_depends_on" {
  type    = any
  default = null
}

variable "environment" {
  description = "The environment of the resource belongs to"
  type        = string
}

variable "product" {
  description = "Product unit the resource belongs to"
  type        = string
}

variable "product_domain" {
  description = "Product domain the resource belongs to"
  type        = string
}

variable "service_name" {
  description = "Service name the resource belongs to"
  type        = string
}

variable "tags" {
  description = "A mapping tags to assign into EC2 instances"
  type        = map
  default     = {}
}

variable "volume_tags" {
  description = "A mapping tags to assign into EC2 volumes (EBS)"
  type        = map
  default     = {}
}

variable "vpc_id" {
  description = "Selected AWS VPC id"
  type        = string
  default     = ""
}

variable "name" {
  description = "AWS EC2 prefix name"
  type        = string
}

variable "instance_count" {
  description = "Number of launched EC2 instances"
  type        = number
  default     = 1
}

variable "instance_ami" {
  description = "Selected AMI id for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to start"
  type        = string
}

variable "use_suffix" {
  description = "Use suffix (number) on launched EC2 instances name"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "The key name to use for the EC2 instance"
  type        = string
  default     = "moka-core"
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "tier" {
  description = "EC2 instance tier type."
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Selected list of subnet ids"
  type        = list(string)
  default     = []
}

variable "private_ips" {
  description = "A list of private IP address to associate with the instance in a VPC. Should match the number of instances."
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  type        = bool
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_names" {
  description = "A list of security group names to associate with"
  type        = list(string)
  default     = []
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = false
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details."
  type        = map(any)
  default     = {}
}

variable "termination_protection" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = false
}

variable "cpu_credits" {
  description = "The credit option for CPU usage (unlimited or standard)"
  type        = string
  default     = "standard"
}
