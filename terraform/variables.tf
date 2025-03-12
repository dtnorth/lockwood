variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "12345678912"
}

variable "trusted_ip_range" {
  description = "Trusted IP range for security group"
  type        = string
  default     = "192.168.1.0/24"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}
