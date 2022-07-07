### PG_DUMP,PG_RESTORE

У PostgreSQL есть специальная утилита — pg_dump для создания логического backup БД.

#### 1. Создание backup и восстановление

      ***1.Простой backup***
      
      pg_dump db_name > dbname_backup.sql - создается backup dbname_backup.sql из БД db_name
      
      Для восстановления из такого бэкапа выполняем следующие команды:
      psql -c 'CREATE DABASE db_name' WITH TEMPLATE template0;
      psql db_name < dbname_backup.sql
      
Если необходимо чтобы восстановление прекратилось при возникновении ошибки:
      psql --set ON_ERROR_STOP=on db_name < dbname_backup.sql
      
      
***2. Создание backup на одном сервере и восстановление на другом***

      pg_dump -h host1 db_name | psql -h host2 db_name
      pg_dump -h 192.168.122.100 db_name | psql -h 192.168.122.101 db_name
      
      Внимание: БД на втором сервере должна быть предварительно создана командой CREATE DATABASE
