# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "ubuntu"
  config.vm.network "private_network", ip: "192.168.10.118"
  config.vbguest.auto_update = false
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y vim git tree
    curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    sudo apt-get install npm -y
    sudo npm install -g gulp coffeelint mocha
  SHELL
end
