# Git repository for pubs portal project.
default['pubs_portal_api']['git_repository'] = 'git@github.com:Via-Bahia-Dev/pubs-portal-api.git'
default['pubs_portal_api']['branch'] = 'master'

default['pubs_portal_front_end']['git_repository'] = 'git@github.com:Via-Bahia-Dev/pubs-portal-front-end.git'
default['pubs_portal_front_end']['branch'] = 'master'

default['ruby']['version'] = '2.1.2'

default['project_dir'] = [ "#{ENV['HOME']}/pubs-portal-api", "#{ENV['HOME']}/pubs-portal-front-end" ]
