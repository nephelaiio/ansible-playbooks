require 'rake'
require 'erb'
require 'find'
require 'pathname'

galaxy_path = './galaxy'
roles_path = './roles'
templates_path = './templates'

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
      sh "ansible-galaxy init #{role} -p #{roles_path}"
      Rake::Task['roles:template'].invoke(role, "#{roles_path}/#{role}")
    end
  end

  task 'template', [:role, :path] do |t, args|
    role_name = args[:role]
    role_path = args[:path]
    template_path = "#{templates_path}/role/#{role_name}"
    Find.find("#{templates_path}/role/") { |file|
      templates_pathname = Pathname.new("#{templates_path}/role")
      file_relname = Pathname.new(file).relative_path_from(templates_pathname)
      target_relname = File.basename("#{roles_path}/#{file_relname}", '.erb')
      target = "#{roles_path}/#{role_name}/#{target_relname}"
      if FileTest.directory?(file)
        Dir.mkdir(target) unless File.exists?(target)
      else
        File.open(file, File::RDWR) do |f|
          template = ERB.new(f.read).result
          File.write(target, template) unless File.exists?(target)
        end 
      end
    }
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
