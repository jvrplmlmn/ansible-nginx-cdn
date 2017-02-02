$script = <<SCRIPT
echo I am provisioning...
date > /etc/vagrant_provisioned_at
apt update
apt install -y python
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.network "forwarded_port", guest: 80, host: 80
  config.vm.network "forwarded_port", guest: 443, host: 443
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provision :shell, inline: $script

  config.vm.provision :ansible do |ansible|
    ansible.playbook = "playbook.yml"
  end
end
