#!/bin/bash
# Basic Backup Script 
# Usage: 
# set crontab to:
# 0 0,12 * * * bash /backup/backup_www_pg.sh
#------------------------------------------------------

# configurar cron para 

find /backup/data/ -type f -mtime +2 -delete

today=$(date +"%d-%m-%Y_%H-%M-%S")

cd /backup/data/

DBLIST=`psql -U postgres -d postgres -q -t -c 'SELECT datname from pg_database'`
for dbin in $DBLIST
do
  echo "db = $dbin";
 	today=$(date +"%d-%m-%Y_%H-%M-%S")
	dbFile=$dbin$today.sql.gz
	pg_dump -c --no-owner -v $dbin -U postgres | gzip -9 > $dbFile
done

# Bakcup dos arquivos do sistema em /var/www/
cd /backup/data/
bkpfile=www_$today.tar.gz 
tar cfz $bkpfile /var/www/ 

# Apaga bakcup remoto (desconmentar para usar) 
#ssh  IP-SERVIDOR 'find /backup/data/ -type f -mtime +3 -delete'

# Sincroniza /backup local com servidor remoto 
# necessário conexão via chave ssh 
rsync -havzP --stats /home/backup/ -e "ssh " IP-SERVIDOR:/backup/
