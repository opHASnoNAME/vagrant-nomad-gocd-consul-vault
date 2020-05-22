
# Configure 

PRIVATE_IP = "172.20.30.10"
MEMORY = 4096
CPUS = 2
NAME = "NomadAndMore"

$msg = <<MSG
------------------------------------------------------------
** This is a playground VM ** Do not use it in production **

ENDPOINTS

- GoCD: http://#{PRIVATE_IP}:8153/
- Consul: http://#{PRIVATE_IP}:8500/ui 
- Nomad: http://#{PRIVATE_IP}:4646/ui
- Vault: http://#{PRIVATE_IP}:8200
- DockerRegistry: localhost:5000
------------------------------------------------------------
MSG

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = NAME
  config.vm.provision :shell, privileged: false, path: "scripts/bootstrap.sh"
  config.vm.provision :shell, privileged: false, path: "scripts/gocd.sh"
  config.vm.provision :shell, privileged: false, path: "scripts/consul.sh"
  config.vm.provision :shell, privileged: false, path: "scripts/docker.sh"
  config.vm.provision :shell, privileged: false, path: "scripts/nomad.sh"
  config.vm.provision :shell, privileged: false, path: "scripts/vault.sh"

  config.vm.network "private_network", ip: PRIVATE_IP
  config.vm.post_up_message = $msg

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.memory = MEMORY
    vb.cpus = CPUS
  end
end