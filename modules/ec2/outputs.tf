output "id" {
  description = "List of EC2 IDs of instances"
  value       = aws_instance.this[*].id
}

output "availability_zone" {
  description = "List of availability zones of EC2 instances"
  value       = aws_instance.this[*].availability_zone
}

output "key_name" {
  description = "List of key names of EC2 instances"
  value       = aws_instance.this[*].key_name
}

output "vpc_security_group_ids" {
  description = "List of associated security groups of instances, if running in non-default VPC"
  value       = aws_instance.this[*].vpc_security_group_ids
}

output "subnet_id" {
  description = "List of IDs of VPC subnets of EC2 instances"
  value       = aws_instance.this[*].subnet_id
}

output "tags" {
  description = "List of tags of EC2 instances"
  value       = aws_instance.this[*].tags
}
