task :install do
  sh "ansible-galaxy install zzet.rbenv -p ./roles/rbenv"
end

task :workstation do
  sh "ansible-playbook workstation.yml --ask-become-pass"
end
