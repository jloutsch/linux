---
layout: default
title: Mount Public Linux NFS Export From Windows Client
categories: [nfs]
tags: [nfs, linux, file_share, windows, firewall]
theme:  jekyll-theme-slate
---
# Mount Public Linux NFS Export From Windows Client

## Environment

|Role|Version|
|---|---|
|NFS Client|Windows 10 Enterprise|
|Server OS|RedHat 7.6|
|NFS Server|1.3.0|

## Problem
Setting up a basic NFS export for a Linux client is a simple task. However, if you have the host based firewall turned on
then you will run into problems when you try to mount from a Windows client. This is because the linux client will
*only* send packets over `2049/tcp` whereas the Windows client will send packets over a total of three ports.

## Solution

### Server

#### Install
If not performed already, install the NFS package
```bash
yum -y install nfs-utils
```

#### Firewall
The three required Windows ports are determined by the RPC services running on the server:

- portmapper (Default `111/tcp`)
- nfs (Default `2049/tcp`)
- mountd (Default `20048/tcp`)

You can determine what these exact ports are by running the following command on the NFS server:

```bash
rpcinfo -p \
  | egrep '(portmapper|mountd|nfs$)' \
  | awk '{print $5" "$4}' \
  | uniq
```

Redhat 7 uses firewalld, so we will allow these ports through the firewall:

```bash
firewall-cmd \
  --add-port=20048/tcp \
  --add-port=111/tcp \
  --add-port=2049/tcp \
  --permanent
firewall-cmd --reload
```

#### Exports
```
# /etc/exports
# all_squash here is important as it 
# maps each user to the NFS anonymous user
/export_test *(rw,all_squash)
```

#### Create export and start server
```
mkdir -p /export_test
chown -R nfsnobody:nfsnobody /export_test
systemctl restart nfs
systemctl enable nfs
```

### Client
You should now be able to create a successful mount from a Windows client (After you've enabled the 
["Services For NFS" Feature](https://mapr.com/docs/60/AdministratorGuide/MountingNFSonWindowsClient.html))
```
mount -o anon \\YOUR-SERVER\export_test z:
```

### Conclusion
All we have done is allow the client to successfully establish a connection to the server. We have also configured
the share to be publicly writeable, and each user is squashed to the nfsnobody user. There is no security here. The goal
was to just establish a working communication between the Windows NFS client, and the Linux NFS server.
