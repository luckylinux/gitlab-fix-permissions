#!/bin/bash

# Change in /etc/gitlab/gitlab.rc
# ENABLE THE FOLLOWING LINES
#
# user['username'] = "gitlab-server"
# user['group'] = "gitlab-server"
# user['uid'] = 2505
# user['gid'] = 2505
#
##! The shell for the git user
# user['shell'] = "/bin/bash"
#
##! The home directory for the git user
# user['home'] = "/var/opt/gitlab"
#

# Disable Account and Storage Management
# Prevent gitlab from setting wrong ACLs, Mask (when doing chmod this can result in mask: ---), etc
#manage_accounts['enable'] = false
#manage_storage_directories['enable'] = false
#manage_storage_directories['manage_etc'] = false


# Fix Permissions Error
# Find out Issues by looking at:
# - gitlab-ctl status -> which service keeps rebooting ? puma / gitaly / etc
# - gitlab-ctl tail puma -> which folder has permissions errors ?
# - gitlab-ctl tail gitaly -> which folder has permissions errors ?

# Fix Permissions
# According to: https://docs.gitlab.com/omnibus/settings/configuration.html#change-the-name-of-the-git-user-or-group
sudo chown -R gitlab-server:gitlab-server /mnt/git/repositories
sudo chown -R gitlab-server:gitlab-server /var/opt/gitlab/gitlab-rails/uploads

# Based on the Log / Process Analysis detailed above
sudo chown -R gitlab-server:gitlab-server /var/opt/gitlab/gitlab-rails/sockets/
sudo chown -R gitlab-server:gitlab-server /opt/gitlab/embedded/service/gitlab-rails/log/
sudo chown -R gitlab-server:gitlab-server /var/log/gitlab/puma
sudo chown -R gitlab-server:gitlab-server /opt/gitlab/var/
sudo chown -R gitlab-server:gitlab-server /var/opt/gitlab/gitaly/
