variable "module_name" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "tags" {
  type = map(any)
}

variable application_sub_domain {
  type = string
}

variable route53_domain {
  type = string
}

variable default_instance_id {
  type = string
}
