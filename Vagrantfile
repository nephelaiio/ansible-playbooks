# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  ubuntu = ["wily"]
  debian = ["jessie"]
  centos = ["7"]

  ubuntu.each do |codename|
    config.vm.define codename do |box|
      box.vm.box = "ubuntu/#{codename}64"
    end
  end

  debian.each do |codename|
    config.vm.define codename do |box|
      box.vm.box = "debian/#{codename}64"
    end
  end

  centos.each do |version|
    config.vm.define "centos#{version}" do |box|
      box.vm.box = "centos/#{version}"
    end
  end

  config.vm.define "arch" do |box|
    box.vm.box = "terrywang/archlinux"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.groups = {
      "ubuntu" => ubuntu,
      "debian" => debian,
      "centos" => centos.map { |x| "centos#{x}" },
      "arch" => "arch",
      "testing:children" => ["ubuntu", "centos", "debian", "arch" ]
    }
    ansible.playbook = "testing.yml"
  end

end
