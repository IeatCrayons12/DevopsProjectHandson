variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# SSH Private Key for EC2 instances
variable "private_key" {
  description = "Path to the private key"
  type        = string
}

variable "public_key" {
  description = "Path to the public key"
  type        = string
}