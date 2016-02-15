# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  ubuntu = ["wily"]
  debian = ["jessie"]
  centos = ["7"]

  ubuntu.each do |codename|
    config.vm.define codename do |box|
      box.vm.box = "ubuntu/#{codename}64"
      box.vm.provision "shell", inline: "apt-get clean ; apt-get update"
      box.vm.provision "ansible" do |ansible|
        ansible.groups = {
          "testing" => codename
        }
        ansible.playbook = "testing.yml"
      end
    end
  end

  debian.each do |codename|
    config.vm.define codename do |box|
      box.vm.box = "debian/#{codename}64"
      box.vm.provision "shell", inline: "apt-get clean ; apt-get update"
      box.vm.provision "ansible" do |ansible|
        ansible.groups = {
          "testing" => codename
        }
        ansible.playbook = "testing.yml"
      end
    end
  end

  centos.each do |version|
    config.vm.define "centos#{version}" do |box|
      box.vm.box = "centos/#{version}"
      box.vm.provision "ansible" do |ansible|
        ansible.groups = {
          "testing" => "centos#{version}"
        }
        ansible.playbook = "testing.yml"
      end
    end
  end

end
