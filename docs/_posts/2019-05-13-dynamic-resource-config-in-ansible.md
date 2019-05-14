---
layout: default
title: Dynamic Resource Allocation in Ansible
categories: [ansible]
tags: [ansible, facts]
theme:  jekyll-theme-slate
---
# Dynamic Resource Allocation in Ansible

Whenever configuring a server, you should always think about what facts are already provided to you for free. I frequently have to refresh my memory of what facts are made available for you:
```bash
ansible $(hostname -s) -m setup -c local
```
While you might already know about the most useful facts (`ansible_hostname`, `ansible_fqdn`, `ansible_default_ipv4`, etc ) you should look at facts that contain resource information about the host.

For example, the fact `ansible_memtotal_mb` can easily be used when rendering a Java configuration that specifies the JVM memory usage. This config will allocate half the total ram on the system to the JVM:

```jinja
# some-jvm-option-file.conf
{%- raw -%}
JAVA_OPTS="-Xms{{ (ansible_memtotal_mb * 0.5) | round | int }}m -Xmx{{ (ansible_memtotal_mb * 0.5) | round | int }}m"
{%- endraw -%}
```


If you ever have to provide a host specific value for a configuration, you should be thinking about what facts you can use, instead of hard coding the value. Using these facts as values in Jinja templates will make your roles significantly more robust, and useful for reusability. 