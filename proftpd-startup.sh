#!/bin/bash

FTP_UID=`id -u www-data`
FTP_GID=`id -g www-data`
FTP_PASSWORD=`cat /etc/secrets/proftpd/password | sed -e 's/[^a-zA-Z0-9]//g'` # allow only nums and chars

cp /etc/proftpd/sql.sql /etc/proftpd/sql-init.sql
echo "INSERT INTO ftpgroup VALUES('www-data',$FTP_GID,'app');" >> /etc/proftpd/sql-init.sql
echo "INSERT INTO ftpuser(userid,passwd,uid,gid,homedir,shell)  VALUES('app','$FTP_PASSWORD',$FTP_UID,$FTP_GID,'/app','/bin/false');" >> /etc/proftpd/sql-init.sql
sqlite3 /etc/proftpd/sql.db ".read /etc/proftpd/sql-init.sql"