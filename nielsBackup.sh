#!/bin/bash

#What this script does:
#	Step 1. Make backup of sql-database
#	Step 2. Make backup of all files in /var/www /etc/nginx (see toBack variable)
#	Step 3. Encrypt
#	Step 4. Upload backups to objectstore, owncloud and s3
#	Step 5. Remove temp backups locally
#	Step 6. remove old backups from objectstore

#path to temp backup place
cd /var/nielsBackup

#settings
dbUser="xxx"
dbPass="xxx"

toBack="/var/www /etc/nginx" #paths to backup, space separated

#credentials objectstore
osUser="xxx"
osPass="xxx"
osPath="https://xxx.objectstore.eu/backups"

#credentials owncloud
ocUser="xxx"
ocPass="xxx"
ocPath="https://xxx.xxx.com/remote.php/webdav/"

#credentials s3
s3region="s3-eu-west-1"
s3bucket="bucketname"
s3path="dir/folfer/path"
s3Key="xxx"
s3Secret="xxx"

#encryption key
gpgKey="xxx"

#number of hours you want to store a backup
maxHours=360

#Step 1. Make backup of sql-database
filenameDate=$(date +%Y-%m-%d-%H-%M-%S)
filenameHostname=$(hostname -f)

#Step 2. Make backup of all files 
mysqldump -u $dbUser --password=$dbPass --all-databases | gzip --best > $filenameHostname-sql-$filenameDate.sql.zip
tar -czf $filenameHostname-www-$filenameDate.zip $toBack

#Step 3. Encrypt
for file in *.zip; do
	echo $gpgKey | gpg --batch -q --passphrase-fd 0 --cipher-algo AES256 -c $file
done

#Step 4. Upload backups
for file in *.gpg; do

	#to objectstore
	curl -X PUT -s -T $file --user $osUser:$osPass $osPath/$file

	#to owncloud
	curl -T $file -u $ocUser:$ocPass -o /dev/stdout $ocPath
	
	#to s3
	contentType="application/zip"
	dateValue=`date -R`
	stringToSign="PUT\n\n${contentType}\n${dateValue}\n/${s3bucket}/${s3path}/${file}"
	signature=$(echo -en "${stringToSign}" | openssl sha1 -hmac "${s3Secret}" -binary | base64)
	curl -X PUT -T "${file}" \
	  -H "Host: ${s3bucket}.s3.amazonaws.com" \
	  -H "Date: ${dateValue}" \
	  -H "Content-Type: ${contentType}" \
	  -H "Authorization: AWS ${s3Key}:${signature}" \
	https://${s3region}.amazonaws.com/${s3path}/${file}
done

#Step 5. Remove temp backups locally
rm *.zip
rm *.gpg

#Step 6. remove old backups from objectstore
maxDate=$(date +%Y%m%d%H%M%S -d "${maxHours} hours ago")
while read fileName
do
	fileDate=$fileName
	fileDate=`expr "$fileDate" : '.*\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}\)'`
	fileDate="${fileDate//-/}"
	if [ $fileDate -lt $maxDate ]; then
		curl -X DELETE -s --user $osUser:$osPass $osPath/$fileName
	fi
done  < <(curl -s --user $osUser:$osPass $osPath)
