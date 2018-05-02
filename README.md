# nielsBackup
Backups your whole MySQL database and complete directories to both OpenStack-object-store and OwnCloud.

## Features
* Backup whole sql databse
* Backup a whole directory-structure including all files and subdirectories
* Backups are encrypted!
* Upload backups to both OpenStack-object-store and OwnCloud
* Filenames of backup-files contain the hostname of the server and a timestamp. So you can backup multiple servers to one OpenStack-object-store/OwnCloud and find them back easily. 
* Backups are automatically removed after a set amount of time

## How to install
1. Put the nielsBackup.sh file somewhere on your server.
1. Make it executable by ```chmod a+x /var/nielsBackup.sh```.
1. Define in the nielsBackup.sh file the path to the temp backup directory. e.g. ```cd /var/nielsBackup```. The script wil use this to temporarily store backups while generating and uploading them.
1. Set database credentials ```dbname``` and ```dbPass```.
1. Specify the path(s) to the folders you want to backup. e.g. ```/var/www /etc/nginx```. The paths must be space separated.
1. Provide OpenStack credentials (```osUser```, ```osPass```, ```osPath```) and OwnCloud credentials (```ocUser```, ```ocPass```, ```ocPath```)
1. Set encryption key (```gpgKey```)
1. Set the amount of hours you want to keep te backups on OpenStack-object-store/OwnCloud in ```maxHours```
1. Create a crontab with ```crontab -e```. e.g. ```1 */6 * * * /var/nielsBackup.sh >/dev/null 2>&1``` to make a backup every six hours.
