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
		env "PATH" => "/opt/rbenv/shims:#{ENV['PATH']}"
		not_if 'bundle check'
	end
end
