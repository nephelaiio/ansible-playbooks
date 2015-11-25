# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.landrush.enabled = true

  ubuntu = ["wily"]
  debian = ["jessie"]
  centos = ["7"]

  ubuntu.each do |codename|
    config.vm.define codename do |box|
      box.vm.box = "ubuntu/#{codename}64"
      box.vm.hostname = "#{codename}.vagrant.dev"
    end
  end

  debian.each do |codename|
    config.vm.define codename do |box|
      box.vm.box = "debian/#{codename}64"
      box.vm.hostname = "#{codename}.vagrant.dev"
    end
  end

  centos.each do |version|
    config.vm.define "centos#{version}" do |box|
      box.vm.box = "centos/#{version}"
      box.vm.hostname = "centos#{version}.vagrant.dev"
    end
  end

  config.vm.provision "ansible" do |ansible|
    ansible.groups = {
      "ubuntu" => ubuntu,
      "debian" => debian,
      "centos" => centos.map { |x| "centos#{x}" },
      "testing:children" => ["ubuntu", "centos", "debian"]
    }
    ansible.playbook = "testing.yml"
  end

end
