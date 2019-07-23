---
layout: default
title: Configure Public Samba Share With no Authentication
categories: [linux]
tags: [samba, linux, file_share]
theme:  jekyll-theme-slate
---
## Purpose
There is a lot of garbage posts online about connecting to a Samba server from a Windows client, and not being prompted for a username/password.
Nothing worked for me so I went through the man page for `smb.conf` (which you should ultimately do too once you get the basic
configuration working). This configuration was tested with Samba version 4.8.3.

## Config
The following is all you need in your `smb.conf` to get this setup working:

```bash
[global]
        map to guest = Bad User

[share]
        path = /share
        browseable = yes
        guest ok = yes
        public = yes
        read only = no
        force create mode = 0666
        force directory mode = 2770
        create mask = 666
        directory mask = 777
        force user = nobody
        force group = nobody
```

## Explanation

1. The key setting here is `map to guest = Bad User`. This is what will silence the username/password prompt.

2. You may now be able to browse the share, but you will likely run into permission problems with reading/writing files.
the share settings are what basically says "Anyone can mount this share, and has read/write access to it". Obviously this is inherently
insecure. It is just a quick config to get a working solution for either a public share, or a proof of concept that you will later harden.

3. Don't forget to perform OS configurations such as creating directories, handling permissions, and configuring SELinux:
```bash
mkdir -p /share
chmod 0777 /share
chown nobody:nobody /share
semanage fcontext -a -t samba_share_t "/share(/.*)?"
restorecon -vR /share
```

## Conclusion
This was just a quick example of a working config that you can hopefully stumble upon on the internet. Always remember to go to the man page if you're coming across bad information :)
