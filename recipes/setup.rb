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

# package 'libpq-dev' # need a sudo apt-get install libpq-dev
gem_package 'bundler' # need a sudo gem install bundler?

# need a bundle install

# installs bundler if not already installed
# execute 'bundle install' do
#   cwd "#{ENV['HOME']}/pubs-portal"
#   not_if 'bundle check'
# end
