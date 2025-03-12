variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "12345678912"                                # Modify as needed
}

variable "trusted_ip_range" {
  description = "Trusted IP range for security group"
  type        = string
  default     = "192.168.1.0/24"                             # Modify as needed
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"                                  # Modify as needed
}

variable "aws_availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]   # Modify as needed
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]               # Modify as needed
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]           # Modify as needed
}

