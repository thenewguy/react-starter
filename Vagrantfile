# -*- mode: ruby -*-
# vi: set ft=ruby :

_script = <<SCRIPT
set -o errexit
set -o pipefail
set -o nounset
shopt -s failglob
set -o xtrace

rm -Rf /vagrant/node_modules
mkdir -p /usr/local/src/vagrant/node_modules
chown vagrant:vagrant /usr/local/src/vagrant/node_modules
ln -s /usr/local/src/vagrant/node_modules /vagrant/node_modules

export DEBIAN_FRONTEND=noninteractive
curl -sL https://deb.nodesource.com/setup_iojs_1.x | sudo bash -
apt-get install -y iojs build-essential

exec sudo -i -u vagrant /bin/bash -- << EOF
cd /vagrant
npm install

EOF
SCRIPT

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/trusty64"
    
    config.vm.provider "virtualbox" do |v|
      unless Vagrant.has_plugin?("vagrant-vbguest")
        raise "Vagrant plugin 'vagrant-vbguest' is not installed! You must run 'vagrant plugin install vagrant-vbguest'! The 'vagrant-vbguest' plugin keeps your VirtualBox Guest Additions up to date in this box."
      end
      v.memory = 1536
      v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
      
      # This is due to a limitation of VirtualBox's built-in networking.  Needed for NFS.
      config.vm.network "private_network", type: "dhcp"
    end
  
    unless !Vagrant::Util::Platform.windows? || Vagrant.has_plugin?("vagrant-winnfsd")
      raise "Vagrant plugin 'vagrant-winnfsd' is not installed! You must run 'vagrant plugin install vagrant-winnfsd'! The 'vagrant-winnfsd' plugin allows folder sharing via NFS on Windows.  Reference http://mitchellh.com/comparing-filesystem-performance-in-virtual-machines for the benefits of using NFS with vagrant."
    end
  
    config.vm.network "forwarded_port", guest: 8080, host: 8080
    config.vm.network "forwarded_port", guest: 2992, host: 2992
    config.vm.provision "shell", inline: _script
    config.vm.synced_folder ".", "/vagrant", type: "nfs"
end
