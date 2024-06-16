# gitlab-fix-permissions
gitlab-fix-permissions

# Introduction
This Repositories tries to address the BREAKING CHANGES occurring after Upgrading from Gitlab 16.x to 17.0.

# Get Started
Clone Repository:
```
git clone https://github.com/luckylinux/gitlab-fix-permissions.git
```

# Preface
I am storing the `git-data` folder on NFS, mounted on `/mnt/git`.

The relevant Setting in `/etc/gitlab/gitlab.rb` is:
```
git_data_dirs({
  "default" => {
    "path" => "/mnt/git"
   }
})
```

Both Client (Gitlab Omnibus Instance) and Server (NAS) are Running Debian Bookworm 12 AMD64.

# NFS Setup
I am running NFS Version 3 over Wireguard VPN in my LAN, as I didn't manage to setup Kerberos Authentication yet and NFSv4 ACLs canb/might be tricky.

Wireguard ensures proper Authentication and Data Encryption.

Client mount options:
```
10.1.1.1:/export/git                                 /mnt/git                      nfs             rw,user=gitlab-server,auto,nofail,x-systemd.automount,nfsvers=3,proto=tcp          0       0
```

Note that I am running NFSv3 in `tcp` mode in order to ensure Data Integrity, since Wireguard is running over UDP.

Server `/etc/exportfs`:
```
/export/git			10.1.1.2/32(rw,no_root_squash,nohide,sync,no_subtree_check,fsid=100)
```

Server `/etc/nfs.conf` - make sure that `manage-gids` is DISABLED (commented) otherwise Secondary Groups will NOT work correctly:
```
[exportd]
#manage-gids=n
[mountd]
#manage-gids=n
```

Server `/etc/defaults/nfs-kernel-server` - make sure that `manage-gids` is DISABLED (commented) otherwise Secondary Groups will NOT work correctly:
```
# Options for rpc.mountd.
# If you have a port-based firewall, you might want to set up
# a fixed port here using the --port option. For more information, 
# see rpc.mountd(8) or http://wiki.debian.org/SecuringNFS
# To disable NFSv4 on the server, specify '--no-nfs-version 4' here
#RPCMOUNTDOPTS="--manage-gids"
RPCMOUNTDOPTS=""
```

Restart NFS Server / Reboot NAS:
```
exportfs -rv
exportfs -a
systemctl restart nfs-server
systemctl restart nfs-kernel-server
```

# Gitlab Configuration Changes
This Section describe the Changes that are required in `/etc/gitlab/gitlab.rc`.

## Change User / Group Name
The default `git` User Name and Group Name can create conflicts on the NAS/NFS, since it doesn't map to the correct uid / gid.

In this case, both the Client (Gitlab Omnibus) and Server (NAS) have:
- User name: `gitlab-server`
- User id (`uid`): `2505`
- Group name: `gitlab-server`
- Group id (`gid`): `2505`

The Configuration in `/etc/gitlab/gitlab.rb` is therefore as follows:
```
user['username'] = "gitlab-server"
user['group'] = "gitlab-server"
user['uid'] = 2505
user['gid'] = 2505

##! The shell for the git user
user['shell'] = "/bin/bash"

##! The home directory for the git user
user['home'] = "/var/opt/gitlab"
```

The `/var/opt/gitlab` line might NOT be required, since it's the default.
I prefer to usee `bash` when having to troubleshoot, instead of `/bin/sh`.
That is per-se however not required.

## Disable Account and Storage Management
This is to prevent gitlab from setting wrong ACLs, Mask (when doing chmod this can result in mask: ---), etc.

The Configuration in `/etc/gitlab/gitlab.rb` is therefore as follows:
```
manage_accounts['enable'] = false
manage_storage_directories['enable'] = false
manage_storage_directories['manage_etc'] = false
```

# Fix Permission Errors
## Get Started
Run
```
./fix_permissions.sh
```

## Troubleshooting

### Which service keeps rebooting ? Looks for Services which have a very low Uptime Value.
In my case `puma` and `gitaly`:
```
gitlab-ctl status
```

### Analyse Service Logs. Look for Errors which indicate Folder/File Permission Errors
Which File/Folder Permissions is preventing `puma` from working correctly ?
```
gitlab-ctl tail puma
```

Which File/Folder Permissions is preventing `gitaly` from working correctly ?
```
gitlab-ctl tail gitaly
```
