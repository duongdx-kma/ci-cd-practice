
variable "vpc_id" {
  description = "The vpc_id"
  type = string
}

variable cidr_blocks_ingress {
  description = "The ingress for cidr block"
  type = list(object({
    from_port = number
    to_port = number
    protocol =  string
    description = string
    cidr_blocks = string
  }))
}

variable security_group_ingress {
  description = "The ingress for with other security group"
  type = list(object({
    from_port = number
    to_port = number
    protocol =  string
    description = string
    source_security_group_id = string
  }))
}

variable tags {
  type = map(any)
}
