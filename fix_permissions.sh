#!/bin/bash

# Load Configuration
source ./config.sh

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
