#
# Cookbook Name:: pubs-portal
# Recipe:: setup
#
# Copyright 2016, Via Bahia Development
#
# All rights reserved - Do Not Redistribute
#
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
include_recipe "rbenv::rbenv_vars"

# SSH keys for pubs portal repos
data_bag_api = data_bag_item('git_deploy_key','pubs_portal_api_git')
data_bag_front_end = data_bag_item('git_deploy_key','pubs_portal_front_end_git')

package 'git'

# Add github.com to the known_hosts file
ssh_known_hosts_entry 'github.com'

# Install ruby with rbenv
rbenv_ruby node['ruby']['version'] do
	global true
end

# Add SSH private keys to /home/vagrant/.ssh
file "#{ENV['HOME']}/.ssh/id_rsa" do
  content data_bag_api['key']
  mode '0400'
  user 'vagrant'
end

file "#{ENV['HOME']}/.ssh/id_rsa_front_end" do
  content data_bag_front_end['key']
  mode '0400'
  user 'vagrant'
end

# Pull pubs portal code from repos
git "#{ENV['HOME']}/pubs-portal-api" do
  repository node[:pubs_portal_api][:git_repository]
  revision node[:pubs_portal_api][:branch]
  user 'vagrant'
  action :sync
end

git "#{ENV['HOME']}/pubs-portal-front-end" do
  repository node[:pubs_portal_front_end][:git_repository]
  revision node[:pubs_portal_front_end][:branch]
  user 'vagrant'
  action :sync
end

# Package required for pg gem
package 'libpq-dev'

# Need to reload OHAI to ensure the newest ruby is loaded up
ohai "reload" do
  action :reload
end

rbenv_gem "bundler" do
  ruby_version "2.1.2"
end

# Run bundle install in project directories
node['project_dir'].each do | project_dir |
	execute 'bundle install' do
		cwd project_dir
		not_if 'bundle check'
	end
end

# Install nodejs for uglifier gem
package 'nodejs'
package 'postgresql'

# Create joypact user with superuser privileges
bash 'create db user' do
  user 'postgres'
  code <<-EOF
  psql -c "CREATE USER joypact WITH PASSWORD 'jesusothersyou' SUPERUSER;"
  EOF
  not_if 'psql -c "\du" | cut -d \| -f 1 | grep -w joypact', :user => 'postgres'
end

bash 'persistent env variables' do
  code <<-EOF
  echo 'export RBENV_ROOT=/opt/rbenv' >> ~/.bashrc
  echo 'export PATH=$RBENV_ROOT/bin:/opt/rbenv/plugins/ruby_build/bin:/opt/rbenv/shims:$PATH' >> ~/.bashrc
  echo 'export DATABASE_PASSWORD=jesusothersyou' >> ~/.bashrc
  echo 'export DATABASE_USERNAME=joypact' >> ~/.bashrc
  source ~/.bashrc
  EOF
end

# Runs rake db:create, db:schema:load, db:seed
bash 'setup db' do
  user 'vagrant'
  cwd "#{ENV['HOME']}/pubs-portal-api"
  code <<-EOF
  /opt/rbenv/versions/2.1.2/bin/rake db:setup
  EOF
end
