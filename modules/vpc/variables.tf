variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to networking resources"
  type        = map(string)
  default     = {}
}