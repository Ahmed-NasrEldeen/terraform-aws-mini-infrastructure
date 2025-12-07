variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be placed"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the EC2 resources"
  type        = map(string)
  default     = {}
}