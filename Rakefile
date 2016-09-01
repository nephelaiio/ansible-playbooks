require 'rake'

galaxy_path = './galaxy'
role_path = './roles'

namespace 'roles' do

  task 'galaxy' do
    sh "ansible-galaxy install zzet.rbenv -p #{galaxy_path}/rbenv"
    sh "ansible-galaxy install geerlingguy.repo-epel -p #{galaxy_path}/epel"
  end

  task 'init' => [ 'galaxy' ]

  task 'generate' do
    ARGV.each { |a| task a.to_sym do ; end }
    Rake::Task['roles:bootstrap'].invoke(ARGV[1..-1])
  end

  task 'bootstrap', [:roles] do |t, args|
    args[:roles].each do |role|
      sh "ansible-galaxy init #{role} -p #{role_path}/#{role}"
    end
  end

end

namespace 'playbooks' do

  task 'workstation' => [ 'roles:init' ] do
    sh "ansible-playbook workstation.yml --ask-become-pass"
  end

  task 'build' do
    sh "ansible-playbook build.yml --ask-become-pass"
  end

end

task 'test' do
end
