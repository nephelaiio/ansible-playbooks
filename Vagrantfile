# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  ubuntu = ["trusty", "wily"]

  centos = ["centos6", "centos7"]

  ubuntu.each do |codename|
    config.vm.define codename do |box|
      box.vm.provider "docker" do |docker|
        docker.build_dir = "dockerfiles"
        docker.dockerfile = "#{codename}"
        docker.has_ssh = true
        docker.cmd = ["/usr/sbin/sshd", "-D"]
        docker.build_args = ["-t", "vagrant:#{codename}"]
      end
    end
  end

  centos.each do |version|
    config.vm.define version do |box|
      box.vm.provider "docker" do |docker|
        docker.build_dir = "dockerfiles"
        docker.dockerfile = "#{version}"
        docker.has_ssh = true
        docker.build_args = ["-t", "vagrant:#{version}"]
      end
      box.vm.hostname = "#{version}.vagrant.dev"
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
