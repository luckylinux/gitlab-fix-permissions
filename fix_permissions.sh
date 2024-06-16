#!/bin/bash

# Define username and groupname
# <username> MUST match user['username'] in /etc/gitlab/gitlab.rb
username="gitlab-server"

# <groupname> MUST match user['group'] in /etc/gitlab/gitlab.rb
groupname="gitlab-server"

# Fix Permissions Error
# Find out Issues by looking at:
# - gitlab-ctl status -> which service keeps rebooting ? puma / gitaly / etc
# - gitlab-ctl tail puma -> which folder has permissions errors ?
# - gitlab-ctl tail gitaly -> which folder has permissions errors ?

# Run Gitlab Reconfigure
sudo gitlab-ctl reconfigure

# Run Checks
sudo gitlab-rake gitlab:check

# Stop all Gitlab Services
sudo gitlab-ctl stop

# Restart runsv Service
sudo systemctl restart gitlab-runsvdir.service

# Restart all Gitlab Services
sudo gitlab-ctl restart

# Fix Permissions
# According to: https://docs.gitlab.com/omnibus/settings/configuration.html#change-the-name-of-the-git-user-or-group
sudo chown -R "${username}":"${groupname}" /mnt/git/repositories
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/uploads

# Based on the Log / Process Analysis detailed above
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/sockets/
sudo chown -R "${username}":"${groupname}" /opt/gitlab/embedded/service/gitlab-rails/log/
sudo chown -R "${username}":"${groupname}" /var/log/gitlab/puma
sudo chown -R "${username}":"${groupname}" /opt/gitlab/var/
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitaly/
