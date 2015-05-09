#!/bin/bash

#path to temp backup place
cd /var/nielsBackup

#settings
dbUser="xxx"
dbPass="xxx"

toBack="/var/www /etc/nginx" #paths to backup, space separated

osUser="xxx"
osPass="xxx"
osPath="https://xxx.objectstore.eu/backups"


#do things
filenameDate=$(date +%Y-%m-%d-%H-%M-%S)

mysqldump -u $dbUser --password=$dbPass --all-databases | gzip --best > sql-backup-$filenameDate.sql.zip
tar -czf www-backup-$filenameDate.zip $toBack

for file in *.zip; do
	curl -X PUT -T $file --user $osUser:$osPass $osPath/$file
done

rm *.zip
