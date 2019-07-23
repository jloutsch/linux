---
layout: default
title: Mount Linux NFS Export From Windows Client
categories: [nfs]
tags: [nfs, linux, file_share, windows, firewall]
theme:  jekyll-theme-slate
---

|Role|Version|
|---|---|
|NFS Client|Windows 10 Enterprise|
|Server OS|RedHat 7.6|
|NFS Server|1.3.0|

# Problem
Setting up a basic NFS export for a Linux client is a simple task. However, if you have the host based firewall turned on
then you will run into problems when you try to mount from a Windows client. This is because the linux client will
*only* send packets over `2049/tcp` whereas the Windows client will send packets over a total of three ports.

# Solution

## Server

### Firewall
The three required Windows ports are determined by the RPC services running on the server:

- portmapper (Default `111/tcp`)
- nfs (Default `2049/tcp`)
- mountd (Default `20048/tcp`)

You can determine what these exact ports are by running the following command on the NFS server:

```
rpcinfo -p | egrep '(portmapper|mountd|nfs$)' | awk '{print $5" "$4}' | uniq
```

Redhat 7 uses firewalld, so we will allow these ports through the firewall:

```
firewall-cmd --add-port=20048/tcp --add-port=111/tcp --add-port=2049/tcp --permanent
firewall-cmd --reload
```

### Exports
```
# /etc/exports
/export_test *(rw)
```
```
systemctl restart nfs
```

## Client
You should now be able to create a successful mount from a Windows client (After you've enabled the 
["Services For NFS" Feature](https://mapr.com/docs/60/AdministratorGuide/MountingNFSonWindowsClient.html))
```
mount -o anon \\your-server\export z:
```

## WARNING
All we have done is allow the client to successfully establish a connection to the server. There is no identity
mapping, or security configurations being performed here. Once you can mount the export, then you should focous on locking it down.
