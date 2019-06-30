#!/bin/bash
backupDir=/mnt/backups/gitlab
configBackup="${backupDir}/gitlab-config.tar.gz"
fullBackupPath=$(find "${backupDir}" -type f -name "*gitlab_backup.tar" -print0 | xargs -0 stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- | head -n 1| awk '{print $4}')
dataBackup=$(basename ${fullBackupPath} _gitlab_backup.tar)

if ! which gitlab-ctl > /dev/null 2>&1; then
        echo "Gitlab is not installed. Cannot continue with restore"
        exit 1
fi

cat << EOF
Performing restore with following backups:

config:           ${configBackup}
data backup path: ${fullBackupPath}
data restore:     ${dataBackup}
EOF

echo "Now performing restore..."
gitlab-ctl start
gitlab-ctl reconfigure
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq

gitlab-ctl status
status="$?"
if [[ "$status" -ne 0 ]] && [[ "$status" -ne 6 ]]; then
        echo "Gitlab return code status: $status"
        echo "Gitlab-ctl status did not return a status value of 0 or 6"
        echo "Can't continue with restore"
        exit 1
fi

echo "Restoring gitlab data..."
gitlab-rake gitlab:backup:restore BACKUP="${dataBackup}"
echo "Restoring gitlab config"
tar -xzvf "${configBackup}" --directory /

gitlab-ctl restart
gitlab-rake gitlab:check SANITIZE=true

