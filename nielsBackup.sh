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

maxHours=100

#create new backups
filenameDate=$(date +%Y-%m-%d-%H-%M-%S)
maxDate=$(date +%Y%m%d%H%M%S -d "${maxHours} hours ago")

mysqldump -u $dbUser --password=$dbPass --all-databases | gzip --best > sql-backup-$filenameDate.sql.zip
tar -czf www-backup-$filenameDate.zip $toBack

#upload new backups to objectstore
for file in *.zip; do
	curl -X PUT -s -T $file --user $osUser:$osPass $osPath/$file
done

#remove new backups locally
rm *.zip

#remove old backups on objectstore
while read fileName
do
	if [ "${fileName//[!0-9]/}" -lt $maxDate ]; then
		curl -X DELETE -s --user $osUser:$osPass $osPath/$fileName
	fi
done  < <(curl -s --user $osUser:$osPass $osPath)
