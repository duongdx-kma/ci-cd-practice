module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.1.2"
  name        = "bastion_sg"
  description = "Security group for bastion host with SSH ports open within VPC"
  vpc_id      = var.vpc_id

  # Ingress rule and CIDR
  ingress_with_cidr_blocks              = var.cidr_blocks_ingress
  ingress_with_source_security_group_id = var.security_group_ingress

  # Egress rules
  egress_rules = ["all-all"]

  # resource tags
  tags = var.tags
}
