variable "module_name" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_key_name" {
  type = string
}

variable "path_to_private_key" {
  type = string
  default = null

  validation {
    condition = !(var.is_worker == true && var.path_to_private_key != null)
    error_message = "path_to_private_key must be NULL when is_worker is true."
  }
}

variable "path_to_worker_key" {
  type = string
  default = null

  validation {
    condition = !(var.is_worker == true && var.path_to_worker_key != null)
    error_message = "path_to_worker_key must be NULL when is_worker is true."
  }
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable detail_monitoring {
  type = bool
  default = false
}

variable is_worker {
  type = bool
  default = false
}

variable path_to_user_data_script {
  type = string
  default = null
}