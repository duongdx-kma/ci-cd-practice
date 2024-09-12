module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = var.module_name
  ami                    = data.aws_ami.amz_linux2.id
  instance_type          = var.instance_type
  key_name               = var.instance_key_name
  monitoring             = var.detail_monitoring
  vpc_security_group_ids = var.vpc_security_group_ids
  subnet_id              = var.subnet_id

  # check ec2 instance log: sudo cat /var/log/cloud-init-output.log
  # Conditionally set user_data only if not a worker instance
  user_data              = var.is_worker ? null : file(var.path_to_user_data_script)

  tags = var.tags
}

resource "null_resource" "copy_ec2_keys" {
  count = var.is_worker ? 0 : 1
  connection {
    timeout     = "2m"
    type        = "ssh"
    host        = module.ec2_instance.public_ip
    user        = "ec2-user"
    private_key = file(var.path_to_private_key)
  }

  # File Provisioner: passing key from local to server
  provisioner "file" {
    source      = var.path_to_worker_key
    destination = "/home/ec2-user/worker.pem"
  }

  # Remote Exec Provisioner Change worker.pem key permission
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 /home/ec2-user/worker.pem"
    ]
  }
}

output "ec2_public_ip" {
  value = module.ec2_instance.public_ip
}