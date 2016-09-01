task :install do
  sh "ansible-galaxy install zzet.rbenv -p ./roles/rbenv"
  sh "ansible-galaxy install geerlingguy.repo-epel -p ./roles/epel"
end

task :workstation => [ :install ] do
  sh "ansible-playbook workstation.yml --ask-become-pass"
end
