variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# SSH Private Key for EC2 instances
variable "private_key" {
  description = "Private SSH key for EC2 instances"
  type        = string
  sensitive   = true
  default = file("/Users/khamushu/keyforaws")
}

variable "public_key" {
  description = "Private SSH key for EC2 instances"
  type        = string
  sensitive   = true
  default     = file("/Users/khamushu/keyforaws.pub")
}