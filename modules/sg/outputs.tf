output "id" {
  description = "The ID of the security group"
  value       = aws_security_group.this.id
}

output "name" {
  description = "The name of the security group"
  value       = aws_security_group.this.name
}

output "description" {
  description = "The description of the security group"
  value       = aws_security_group.this.description
}

output "vpc_id" {
  description = "The VPC ID where the security group placed"
  value       = aws_security_group.this.vpc_id
}

output "tags" {
  description = "List of tags of the security group"
  value       = aws_security_group.this.tags
}
