locals {
  owners      = var.owner
  environment = var.environment

  name = "${var.stack_name}-${var.environment}"
  common_tags = {
    owner       = local.owners
    environment = local.environment
    GithubRepo  = "jenkins-nexus-ansible-docker-terraform"
    GithubUser  = "duongdx-kma"
  }
}

module "vpc" {
  source                                 = "../modules/vpc"
  vpc_name                               = "vpc-${var.stack_name}-${var.environment}"
  aws_region                             = var.aws_region
  environment                            = var.environment
  vpc_create_database_subnet_group       = true
  vpc_create_database_subnet_route_table = true
  vpc_enable_nat_gateway                 = false # set false for testing
  vpc_single_nat_gateway                 = true

  public_subnet_tags = {
    Type = "Public Subnets"
  }

  private_subnet_tags = {
    Type = "Private Subnets"
  }

  database_subnet_tags = {
    Type = "Private Database Subnets"
  }
}

module "security-groups" {
  source = "../modules/security-groups"
  vpc_id = module.vpc.vpc_id
  bastion_host_ingress = [{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "The ingress for ssh protocol"
    cidr_blocks = "0.0.0.0/0"
  }]

  jenkins_ingress = [{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "The ingress for ssh protocol"
    cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "The ingress for jenkins"
      cidr_blocks = "0.0.0.0/0"
  }]

  tags = local.common_tags
}

module "bastion_key" {
  source             = "../modules/ec2-key-pair"
  key_name           = "ec2-bastion-key-pair"
  path_to_public_key = "keys/bastion-key.pem.pub"
}

# terraform apply -auto-approve -target=module.vpc -target=module.security-groups -target=module.bastion_key -target=module.jenkins
module "jenkins" {
  source                   = "../modules/ec2-instance"
  module_name              = "jenkins-host"
  instance_name            = "jenkins-instance"
  instance_type            = "t3.small"
  instance_key_name        = module.bastion_key.bastion_key_name
  path_to_user_data_script = "../scripts/install-jenkins.sh"
  path_to_private_key      = "keys/bastion-key.pem"
  path_to_worker_key       = "keys/worker.pem"
  vpc_security_group_ids   = [module.security-groups.jenkins_sg_id]
  subnet_id                = module.vpc.public_subnets[0]

  tags = merge(
    local.common_tags,
    {
      Name = "Jenkins-Server"
    }
  )
}

module "worker_key" {
  source             = "../modules/ec2-key-pair"
  key_name           = "ec2-worker-key-pair"
  path_to_public_key = "keys/worker.pem.pub"
}

# module "maven_instance" {
#   source                   = "../modules/ec2-instance"
#   is_worker                = true
#   module_name              = "maven-host"
#   instance_name            = "maven-instance"
#   instance_type            = "t3.micro"
#   instance_key_name        = module.worker_key.bastion_key_name
#   path_to_user_data_script = "../scripts/install-maven-as-jenkins-agent.sh"
#   vpc_security_group_ids   = [module.security-groups.jenkins_agent_sg_id]
#   subnet_id                = module.vpc.public_subnets[1]

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "Maven-Server"
#     }
#   )
# }

module "web_server" {
  source                   = "../modules/ec2-instance"
  is_worker                = true
  module_name              = "web-server"
  instance_name            = "web-server-instance"
  instance_type            = "t3.micro"
  instance_key_name        = module.worker_key.bastion_key_name
  path_to_user_data_script = "../scripts/install-tomcat.sh"
  vpc_security_group_ids   = [module.security-groups.public_webserver_sg_id]
  subnet_id                = module.vpc.public_subnets[0]

  tags = merge(
    local.common_tags,
    {
      Name = "Web-Server"
    }
  )
}

# module "ansible_control_host" {
#   source                   = "../modules/ec2-instance"
#   module_name              = "ansible-control-host"
#   instance_name            = "ansible-control-instance"
#   instance_type            = "t3.micro"
#   instance_key_name        = module.bastion_key.bastion_key_name
#   path_to_user_data_script = "../scripts/install-ansible.sh"
#   path_to_private_key      = "keys/bastion-key.pem"
#   path_to_worker_key       = "keys/worker.pem"
#   vpc_security_group_ids   = [module.security-groups.bastion_sg_id]
#   subnet_id                = module.vpc.public_subnets[1]

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "Ansible-Control-Host"
#     }
#   )
# }
