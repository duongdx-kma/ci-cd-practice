variable "aws_region" {
  type        = string
  description = "The AWS default region"
  default     = "ap-southeast-1"
}

variable "owner" {
  type        = string
  description = "The cluster owner name"
  default     = "duongdx"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}

variable "stack_name" {
  type        = string
  description = "The stack name"
  default = "ci-cd"
}