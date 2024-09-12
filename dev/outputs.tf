output "jenkins_public_ip" {
  value = module.jenkins.ec2_public_ip
}

output "ansible_public_ip" {
  value = module.ansible_control_host.ec2_public_ip
}