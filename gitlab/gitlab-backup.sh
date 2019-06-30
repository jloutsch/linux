#!/bin/bash
/bin/tar -czvf /mnt/backups/gitlab/gitlab-config.tar.gz /etc/gitlab
sudo -u git /bin/gitlab-rake gitlab:backup:create CRON=1
