# Vagrantfile for SOC Lab (Hybrid)
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use VirtualBox provider
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 2
  end

  # Host-only network (so host <-> guests and guests <-> guests)
  # VirtualBox will create a host-only adapter (e.g. 192.168.56.0/24)
  config.vm.network "private_network", ip: "192.168.56.10", auto_correct: true

  ############################
  # Ubuntu SIEM Server (Wazuh + ELK)
  ############################
  config.vm.define "siem" do |siem|
    siem.vm.box = "ubuntu/jammy64"           # Ubuntu 22.04 LTS
    siem.vm.hostname = "siem.local"
    siem.vm.network "private_network", ip: "192.168.56.10"
    siem.vm.provider "virtualbox" do |vb|
      vb.memory = 8192
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--vram", "16"]
    end
    siem.vm.provision "shell", path: "provision/install_wazuh.sh", args: ["192.168.56.10"]
  end

  ############################
  # Kali Attacker
  ############################
  config.vm.define "kali" do |kali|
    kali.vm.box = "kalilinux/rolling"
    kali.vm.hostname = "kali.local"
    kali.vm.network "private_network", ip: "192.168.56.11"
    kali.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus = 1
    end
    kali.vm.provision "shell", path: "provision/install_kali_tools.sh"
  end

  # Sync folder (optional): host ./shared -> /home/vagrant/shared in VMs
  config.vm.synced_folder "./shared", "/home/vagrant/shared", create: true
end
