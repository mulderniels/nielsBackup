#!/bin/bash

cd /var/nielsBackup

mysqldump -u xxx --password=xxx --all-databases | gzip --best > sql-backup-$(date +%Y-%m-%d-%H-%M-%S).sql.zip
tar -czf www-backup-$(date +%Y-%m-%d-%H-%M-%S).zip /var/www /etc/nginx

for file in *.zip; do
	curl -X PUT -T $file --user xxx:xxx https://xxx.objectstore.eu/backups/$file
done

rm *.zip
