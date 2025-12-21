# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Use Ubuntu 20.04 (Focal Fossa)
  config.vm.box = "ubuntu/focal64"

  # Provisioning using the setup_ubuntu.sh script
  config.vm.provision "shell", path: "setup_ubuntu.sh"

  # VM Resources configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.name = "cloud-1-dev-env"
  end

  # Optional: Forward ports if needed for development
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Optional: Shared folder for working locally
  # config.vm.synced_folder ".", "/home/vagrant/project"

  config.vm.post_up_message = <<-MESSAGE
    --------------------------------------------------------------
    VM is ready! Terraform and gcloud CLI have been installed.
    
    To start working:
     1. Run 'vagrant ssh'
     2. Run 'gcloud init' inside the VM
    --------------------------------------------------------------
  MESSAGE
end
