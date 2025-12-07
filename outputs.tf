output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.network.vpc_id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.web.instance_id
}

output "public_ip" {
  description = "Public IPv4 address of the EC2 instance"
  value       = module.web.public_ip
}