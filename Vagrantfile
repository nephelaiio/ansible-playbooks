# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.landrush.enabled = true

  ubuntu = ["trusty", "wily"]

  centos = ["7"]

  ubuntu.each do |codename|
    config.vm.define codename do |box|
      box.vm.box = "ubuntu/#{codename}64"
    end
  end

  centos.each do |version|
    config.vm.define "centos#{version}" do |box|
      box.vm.box = "centos/#{version}"
    end
  end

  config.vm.provision "ansible" do |ansible|
    ansible.groups = {
      "ubuntu" => ubuntu,
      "centos" => centos,
      "testing:children" => ["ubuntu", "centos"]
    }
    ansible.playbook = "testing.yml"
  end

end
