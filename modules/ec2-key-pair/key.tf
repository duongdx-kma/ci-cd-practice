variable "path_to_public_key" {
  type = string
}

variable "key_name" {
  type = string
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = file(var.path_to_public_key)
}

output "key_name" {
  value = aws_key_pair.this.key_name
}