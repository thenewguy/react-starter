# -*- mode: ruby -*-
# vi: set ft=ruby :

_script = <<SCRIPT
set -o errexit
set -o pipefail
set -o nounset
shopt -s failglob
set -o xtrace

rm -Rf /vagrant/node_modules
mkdir -p /var/opt/node_modules
chown vagrant:vagrant /var/opt/node_modules
ln -s /var/opt/node_modules /vagrant/node_modules

export DEBIAN_FRONTEND=noninteractive
curl -sL https://deb.nodesource.com/setup_iojs_2.x | bash -
apt-get install -y iojs build-essential

npm install -g npm@3

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
  
    unless Vagrant.has_plugin?("vagrant-winnfsd")
      raise "Vagrant plugin 'vagrant-winnfsd' is not installed! You must run 'vagrant plugin install vagrant-winnfsd'! The 'vagrant-winnfsd' plugin allows folder sharing via NFS on Windows.  This is required to overcome Windows's default 250ish character path length restriction."
    end
  
    config.vm.synced_folder ".", "/vagrant", type: "nfs"

    config.vm.provision "shell", inline: _script
    config.vm.network "forwarded_port", guest: 8080, host: 8080
    config.vm.network "forwarded_port", guest: 2992, host: 2992
end
