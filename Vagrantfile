Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-22.04"
    config.vm.box_check_update = false

    config.vm.define "jenkins" do |node|
        node.vm.provider "virtualbox" do |vb|
        vb.name = "jenkins"
        vb.memory = 2048
        vb.cpus = 2
        end
        node.vm.hostname = "jenkins"
        node.vm.network :private_network, ip: "192.168.63.15"
        node.vm.network "forwarded_port", guest: 22, host: "61221"
        node.vm.provision "setup-dns", type: "shell", :path => "./scripts/dns-setup.sh"
        node.vm.provision "setup-jenkins", type: "shell", :path => "./scripts/ubuntu/install-jenkins.sh"
    end

    config.vm.define "sonarqube" do |node|
        node.vm.provider "virtualbox" do |vb|
        vb.name = "sonarqube"
        vb.memory = 2048
        vb.cpus = 2
        end
        node.vm.hostname = "sonarqube"
        node.vm.network :private_network, ip: "192.168.63.16"
        node.vm.network "forwarded_port", guest: 22, host: "61222"
        node.vm.provision "setup-dns", type: "shell", :path => "./scripts/dns-setup.sh"
        node.vm.provision "setup-sonarqubes", type: "shell", :path => "./scripts/ubuntu/install-sonarqube.sh"
    end

    config.vm.define "nexus" do |node|
        node.vm.provider "virtualbox" do |vb|
        vb.name = "nexus"
        vb.memory = 4096
        vb.cpus = 2
        end
        node.vm.hostname = "nexus"
        node.vm.network :private_network, ip: "192.168.63.18"
        node.vm.network "forwarded_port", guest: 22, host: "61223"
        node.vm.provision "setup-dns", type: "shell", :path => "./scripts/dns-setup.sh"
        node.vm.provision "setup-nexus", type: "shell", :path => "./scripts/ubuntu/install-nexus-repository.sh"
    end

    config.vm.define "maven" do |node|
        node.vm.provider "virtualbox" do |vb|
        vb.name = "maven"
        vb.memory = 1024
        vb.cpus = 1
        end
        node.vm.hostname = "maven"
        node.vm.network :private_network, ip: "192.168.63.26"
        node.vm.network "forwarded_port", guest: 22, host: "61226"
        node.vm.provision "setup-dns", type: "shell", :path => "./scripts/dns-setup.sh"
        node.vm.provision "setup-maven", type: "shell", :path => "./scripts/ubuntu/install-maven.sh"
    end

    config.vm.provision "setup-deployment-user", type: "shell" do |s|
        ssh_pub_key = File.readlines("./dev/keys/bastion-key.pem.pub").first.strip
        s.inline = <<-SHELL
            # create deploy user
            useradd -s /bin/bash -d /home/deploy/ -m -G sudo deploy
            echo 'deploy ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
            mkdir -p /home/deploy/.ssh && chown -R deploy /home/deploy/.ssh
            echo #{ssh_pub_key} >> /home/deploy/.ssh/authorized_keys
            chown -R deploy /home/deploy/.ssh/authorized_keys
            # config timezone
            timedatectl set-timezone Asia/Ho_Chi_Minh
        SHELL
    end
end
