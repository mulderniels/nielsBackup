# nielsBackup
Backups the whole MySQL database and complete folders to OpenStack/Swift object store.

## How to install
1. Put the file somewhere on your server.
2. Make it executable by ```chmod a+x /var/nielsBackup.sh```.
3. Define in the nielsBackup.sh file the path to the temp backup location. e.g. ```cd /var/nielsBackup```.
4. Set database credentials ```dbname``` and ```dbPass```.
5. Specify the path(s) to the folders you want to backup. e.g. ```/var/www /etc/nginx```. The paths must be space separated.
6. Provide OpenStack/Swift settings ```osUser```, ```osPass``` and ```osPath```.
7. Create a crontab with ```crontab -e```. e.g. ```1 */6 * * * /var/nielsBackup.sh >/dev/null 2>&1``` to make a backup every six hours.
