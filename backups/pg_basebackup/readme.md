### Работа с pg_basebackup
#### Создание backup с удаленного сервера где развернут кластер Postgresql

#### Создание backup с удаленного сервера где развернут кластер Postgresql

    pg_basebackup -D /pgdata/zabbix-data -P -X stream -c fast  -h 10.0.100.11 -p 5432 -U postgres - создание файлового backup кластера Postgresql c хоста 10.0.100.11

1. Владельцем каталога куда будет создан backup (/pgdata/zabbix-data) должен быть postgres

      sudo chown -R postgres:postgres /pgdata/zabbix-data
      sudo chmod -R 700 /pgdata/zabbix-data
  
2. Для создания backup в файле pg_hba.conf для пользователя postgres в разделе Replicatiom должна быть создана строка:
       host    replication     all             10.0.100.0/24               trust
       или
       host    replication     all             0.0.0.0/0                   trust
       
И соответственно применены внесенные изменения на сервере с которого будет выполнен backup

### Описание параметров pg_basebackup
