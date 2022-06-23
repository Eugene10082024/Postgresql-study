### Работа с pg_basebackup

#### Создание backup локально, на сервер где работает кластер Postgresql

        /usr/pgsql-13/bin/pg_basebackup -c fast -P  -h 127.0.0.1 -U postgres -D /pgdump/backups/2022-06-09
        
  1. Владельцем каталога куда будет создан backup (/pgdump/backups/2022-06-09) должен быть postgres

                sudo chown -R postgres:postgres /pgdump/backups/2022-06-09
                sudo chmod -R 700 /pgdump/backups/2022-06-09
  
2. Для создания backup в файле pg_hba.conf для пользователя postgres в разделе Replication должна быть создана строка:

                  host    replication     all             127.0.0.1/32              trust

       
И соответственно применены внесенные изменения на сервере с которого будет выполнен backup      
       

#### Создание backup с удаленного сервера где развернут кластер Postgresql

        pg_basebackup -D /pgdata/zabbix-data -P -X stream -c fast  -h 10.0.100.11 -p 5432 -U postgres 
        
где: 
   -h <IP> - указывается IP адрес источника

1. Владельцем каталога куда будет создан backup (/pgdata/zabbix-data) должен быть postgres

        sudo chown -R postgres:postgres /pgdata/zabbix-data
        sudo chmod -R 700 /pgdata/zabbix-data
  
2. Для создания backup в файле pg_hba.conf для пользователя postgres в разделе Replication должна быть создана строка:

       host    replication     all             10.0.100.0/24               trust
       или
       host    replication     all             0.0.0.0/0                   trust
       
И соответственно применены внесенные изменения на сервере с которого будет выполнен backup
        
####  Создание backup с master server при настройке репликации       

192.168.122.150 - IP адрес Master server
        
192.168.122.151 - IP адрес Slave server

Добавляем следующие строки в pg_hba.conf:
        
        host    replication     postgres    192.168.122.151/32      trust
        host    replication     postgres    192.168.122.150/32      trust    

Выполняем утилиту на будущей реплике.
        
        pg_basebackup -h 192.168.122.150 -U postgres -p 5432 -D /var/lib/pgpro/std-14/backup/ -Fp -Xs -P -R

        

### Описание параметров pg_basebackup

**-с fast** -         
        
**-P** - будет отображать прогресс в действиях      
        
**-X stream** - используем stream, а не fetch      

**-U user** - пользователь user . Данный пользователь должен обладать правами репликации в БД и прописан в pg_hba.conf

**-h сервер** - Указывает имя компьютера, на котором работает сервер. Если значение начинается с косой черты, оно определяет каталог Unix-сокета. Значение по умолчанию берётся из переменной окружения PGHOST, если она установлена. В противном случае выполняется подключение к Unix-сокету.  
        
**-p порт** - указывается порт подключения        
 
        
