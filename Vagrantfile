# -*- mode: ruby -*-
# vi: set ft=ruby :

_script = <<SCRIPT
set -o errexit
set -o pipefail
set -o nounset
shopt -s failglob
set -o xtrace

rm -Rf /vagrant/node_modules
mkdir -p /var/tmp/vagrant/node_modules
chown vagrant:vagrant /var/tmp/vagrant/node_modules
ln -s /var/tmp/vagrant/node_modules /vagrant/node_modules

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
    
    # cpu/mem algorithm adapted from https://github.com/rdsubhas/vagrant-faster/blob/master/lib/vagrant/faster/action.rb
    # because 'vagrant-faster' is VirtualBox specific and unconditionally targets all virtual machines at time of writing
    mem = 2048
    cpus = 1
    host = RbConfig::CONFIG['host_os']
    if host =~ /darwin/
        mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024
        cpus = `sysctl -n hw.ncpu`.to_i
    elsif host =~ /linux/
        mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024
        cpus = `nproc`.to_i
    elsif host =~ /mswin|mingw|cygwin/
        mem = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i / 1024 / 1024
        cpus = `wmic cpu Get NumberOfCores`.split[1].to_i
    end
    mem  = (mem / 2.to_f).ceil.to_i
    cpus = (cpus / 1.5).ceil.to_i
    
    config.vm.provider "virtualbox" do |v|
      unless Vagrant.has_plugin?("vagrant-vbguest")
        raise "Vagrant plugin 'vagrant-vbguest' is not installed! You must run 'vagrant plugin install vagrant-vbguest'! The 'vagrant-vbguest' plugin keeps your VirtualBox Guest Additions up to date in this box."
      end
      
      # VirtualBox disables symlinks in synced folders by default for security
      v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
      
      v.memory = mem
      v.cpus = cpus
      if cpus > 1
        v.customize ["modifyvm", :id, "--ioapic", "on"]
      end
      v.customize ["modifyvm", :id, "--cpuexecutioncap", "75"]
    end
    
    config.vm.provider "vmware_fusion" do |v|
      v.vmx["memsize"] = mem.to_s
      v.vmx["numvcpus"] = cpus.to_s
    end
    
    config.vm.provider "hyperv" do |v|
      v.memory = mem
      v.maxmemory = mem
      v.cpus = cpus
    end
    
    config.vm.provider :parallels do |v, override|
      v.customize ["set", :id, "--memsize", mem.to_s, "--cpus", cpus.to_s]
    end
  
    unless !Vagrant::Util::Platform.windows? || Vagrant.has_plugin?("vagrant-winnfsd")
      raise "Vagrant plugin 'vagrant-winnfsd' is not installed! You must run 'vagrant plugin install vagrant-winnfsd'! The 'vagrant-winnfsd' plugin allows folder sharing via NFS on Windows."
    end
    
    config.vm.network "forwarded_port", guest: 8080, host: 8080
    config.vm.network "forwarded_port", guest: 2992, host: 2992
    config.vm.provision "shell", inline: _script
    
    # This is due to a limitation of VirtualBox's built-in networking.  Needed for NFS.
    # Set this globally to be consistent
    config.vm.network "private_network", type: "dhcp"
    
    # For the benefits of using NFS to sync folders reference:
    #   http://mitchellh.com/comparing-filesystem-performance-in-virtual-machines
    # If you decide against using NFS and are using VirtualBox as your provider,
    # take note of the caveats listed at the following link:
    #   https://docs.vagrantup.com/v2/synced-folders/virtualbox.html
    config.vm.synced_folder ".", "/vagrant", type: "nfs"
end
