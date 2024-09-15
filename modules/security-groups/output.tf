# bastion-host SG output
output "bastion_sg_arn" {
  description = "The ARN of the security group"
  value       = module.bastion_sg.security_group_arn
}

output "bastion_sg_id" {
  description = "The ID of the security group"
  value       = module.bastion_sg.security_group_id
}

output "bastion_sg_vpc_id" {
  description = "The VPC ID"
  value       = module.bastion_sg.security_group_vpc_id
}

output "bastion_sg_owner_id" {
  description = "The owner ID"
  value       = module.bastion_sg.security_group_owner_id
}

output "bastion_sg_name" {
  description = "The name of the security group"
  value       = module.bastion_sg.security_group_name
}

output "bastion_sg_description" {
  description = "The description of the security group"
  value       = module.bastion_sg.security_group_description
}

# jenkins SG output
output "jenkins_sg_arn" {
  description = "The ARN of the security group"
  value       = module.jenkins_sg.security_group_arn
}

output "jenkins_sg_id" {
  description = "The ID of the security group"
  value       = module.jenkins_sg.security_group_id
}

output "jenkins_sg_vpc_id" {
  description = "The VPC ID"
  value       = module.jenkins_sg.security_group_vpc_id
}

output "jenkins_sg_owner_id" {
  description = "The owner ID"
  value       = module.jenkins_sg.security_group_owner_id
}

output "jenkins_sg_name" {
  description = "The name of the security group"
  value       = module.jenkins_sg.security_group_name
}

output "jenkins_sg_description" {
  description = "The description of the security group"
  value       = module.jenkins_sg.security_group_description
}

# Jenkins Agents SG output
output "jenkins_agent_sg_arn" {
  description = "The ARN of the security group"
  value       = module.jenkins_agent_sg.security_group_arn
}

output "jenkins_agent_sg_id" {
  description = "The ID of the security group"
  value       = module.jenkins_agent_sg.security_group_id
}

output "jenkins_agent_sg_vpc_id" {
  description = "The VPC ID"
  value       = module.jenkins_agent_sg.security_group_vpc_id
}

output "jenkins_agent_sg_owner_id" {
  description = "The owner ID"
  value       = module.jenkins_agent_sg.security_group_owner_id
}

output "jenkins_agent_sg_name" {
  description = "The name of the security group"
  value       = module.jenkins_agent_sg.security_group_name
}

output "jenkins_agent_sg_description" {
  description = "The description of the security group"
  value       = module.jenkins_agent_sg.security_group_description
}

# public webserver SG output
output "public_webserver_sg_arn" {
  description = "The ARN of the security group"
  value       = module.public_webserver_sg.security_group_arn
}

output "public_webserver_sg_id" {
  description = "The ID of the security group"
  value       = module.public_webserver_sg.security_group_id
}

output "public_webserver_sg_vpc_id" {
  description = "The VPC ID"
  value       = module.public_webserver_sg.security_group_vpc_id
}

output "public_webserver_sg_owner_id" {
  description = "The owner ID"
  value       = module.public_webserver_sg.security_group_owner_id
}

output "public_webserver_sg_name" {
  description = "The name of the security group"
  value       = module.public_webserver_sg.security_group_name
}

output "public_webserver_sg_description" {
  description = "The description of the security group"
  value       = module.public_webserver_sg.security_group_description
}

# jenkins SG output
output "sonar_sg_arn" {
  description = "The ARN of the security group"
  value       = module.sonar_sg.security_group_arn
}

output "sonar_sg_id" {
  description = "The ID of the security group"
  value       = module.sonar_sg.security_group_id
}

output "sonar_sg_vpc_id" {
  description = "The VPC ID"
  value       = module.sonar_sg.security_group_vpc_id
}

output "sonar_sg_owner_id" {
  description = "The owner ID"
  value       = module.sonar_sg.security_group_owner_id
}

output "sonar_sg_name" {
  description = "The name of the security group"
  value       = module.sonar_sg.security_group_name
}

output "sonar_sg_description" {
  description = "The description of the security group"
  value       = module.sonar_sg.security_group_description
}
