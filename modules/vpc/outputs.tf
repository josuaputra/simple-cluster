output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet ids"
  value = [
    for subnet in aws_subnet.public :
    subnet.id
  ]
}

output "app_subnet_ids" {
  description = "List of application subnet ids"
  value = [
    for subnet in aws_subnet.app :
    subnet.id
  ]
}

output "middleware_subnet_ids" {
  description = "List of middleware subnet ids"
  value = [
    for subnet in aws_subnet.middleware :
    subnet.id
  ]
}

output "general_subnet_ids" {
  description = "List of general subnet ids"
  value = [
    for subnet in aws_subnet.general :
    subnet.id
  ]
}

output "intra_subnet_ids" {
  description = "List of intra subnet ids"
  value = [
    for subnet in aws_subnet.intra :
    subnet.id
  ]
}


output "custom_public_subnet_ids" {
  description = "List of public subnet ids on non-default network setup"
  value = [
    for subnet in aws_subnet.custom_public :
    subnet.id
  ]
}

output "custom_middleware_private_subnet_ids" {
  description = "List of database private subnet ids on non-default network setup"
  value = [
    for subnet in aws_subnet.custom_middleware_private :
    subnet.id
  ]
}

output "custom_app_private_subnet_ids" {
  description = "List of application private subnet ids on non-default network setup"
  value = [
    for subnet in aws_subnet.custom_app_private :
    subnet.id
  ]
}

output "custom_general_private_subnet_ids" {
  description = "List of utility private subnet ids on non-default network setup"
  value = [
    for subnet in aws_subnet.custom_general_private :
    subnet.id
  ]
}

output "custom_intra_subnet_ids" {
  description = "List of intra subnet ids on non-default network setup"
  value = [
    for subnet in aws_subnet.custom_intra :
    subnet.id
  ]
}
