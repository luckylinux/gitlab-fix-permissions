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

# According to: https://docs.gitlab.com/omnibus/settings/configuration.html#disable-the-varoptgitlab-directory-management
sudo chown -R "${username}":gitlab-www /var/opt/gitlab/gitlab-rails/shared
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/shared/artifacts
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/shared/external-diffs
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/shared/lfs-objects
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/shared/packages
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/shared/dependency_proxy
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/shared/terraform_state
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/shared/ci_secure_files
sudo chown -R "${username}":gitlab-www /var/opt/gitlab/gitlab-rails/shared/pages
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/shared/uploads
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-ci/builds

# Suggested by gitlab check
sudo chmod 700 /var/opt/gitlab/.ssh
sudo touch /var/opt/gitlab/.ssh/authorized_keys
sudo chmod 600 /var/opt/gitlab/.ssh/authorized_keys

# Fix SSH Keys Permissions
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/.ssh

# Based on the Log / Process Analysis detailed above
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitlab-rails/sockets/
sudo chown -R "${username}":"${groupname}" /opt/gitlab/embedded/service/gitlab-rails/log/
sudo chown -R "${username}":"${groupname}" /var/log/gitlab/puma
sudo chown -R "${username}":"${groupname}" /opt/gitlab/var/
sudo chown -R "${username}":"${groupname}" /var/opt/gitlab/gitaly/

# Reconfigure again
sudo gitlab-ctl reconfigure

# Restart all Services again
sudo gitlab-ctl restart
