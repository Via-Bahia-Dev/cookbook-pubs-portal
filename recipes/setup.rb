#
# Cookbook Name:: pubs-portal
# Recipe:: setup
#
# Copyright 2016, Via Bahia Development
#
# All rights reserved - Do Not Redistribute
#
data_bag = data_bag_item('git_deploy_key','pubs_portal_git')

# package 'ruby' do
# 	action :upgrade
# end

bash 'ruby dependencies' do
 code <<-EOF
  sudo apt-get update
	sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev -y
	EOF
end

bash 'install ruby' do
	code <<-EOF
	cd
	git clone git://github.com/sstephenson/rbenv.git .rbenv
	sudo chown vagrant:vagrant .rbenv
	echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
	echo 'eval "$(rbenv init -)"' >> ~/.bashrc
	exec $SHELL

	git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
	echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
	exec $SHELL

	rbenv install 2.2.0
	rbenv global 2.2.0
	ruby -v
	EOF
end

package 'git'

ssh_known_hosts_entry 'github.com'

file "#{ENV['HOME']}/.ssh/id_rsa" do
  content data_bag['key']
  mode '0400'
  user 'vagrant'
end

git "#{ENV['HOME']}/pubs-portal" do
  repository node[:pubs_portal][:git_repository]
  revision node[:pubs_portal][:git_revision]
  user 'vagrant'
  action :sync
end

package 'libpq-dev' # need a sudo apt-get install libpq-dev
gem_package 'bundler' # need a sudo gem install bundler?

# need a bundle install

# installs bundler if not already installed
# execute 'bundle install' do
#   cwd "#{ENV['HOME']}/pubs-portal"
#   not_if 'bundle check'
# end
