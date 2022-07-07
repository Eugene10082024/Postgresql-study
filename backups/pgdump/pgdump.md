### PG_DUMP, PG_RESTORE

У PostgreSQL есть специальная утилита — pg_dump для создания логического backup БД.

#### 1. Создание backup и восстановление

***1.1. Простой backup***
      
      pg_dump db_name > dbname_backup.sql - создается backup dbname_backup.sql из БД db_name
      
      Для восстановления из такого бэкапа выполняем следующие команды:
      psql -c 'CREATE DABASE db_name' WITH TEMPLATE template0;
      psql db_name < dbname_backup.sql
      
Если необходимо чтобы восстановление прекратилось при возникновении ошибки:
      psql --set ON_ERROR_STOP=on db_name < dbname_backup.sql

***1.2. Создание backup и восстановление с использованием сжатия***

     pg_dump dbname | gzip > filename.gz

     Восстановление
	gunzip -c filename.gz | psql dbname
     
     или 
     
	cat filename. gz | gunzip | psql dbname

***1.3. Вывод backup в файлы меньшего размера ***

     pg_dump dbname | split -b 1m - filename - созданные файлы backup будут размеров в 1mb
     
     Восстановление
     cat filename* | psql dbname
     
***1.4. Использование пользовательского формата дампа pg_dump***

PostgreSQL построен на системе с библиотекой сжатия Zlib, поэтому пользовательский формат бэкапа будет в сжатом виде. Это похоже на метод с использованием GZIP, но он имеет дополнительное преимущество — таблицы могут быть восстановлены выборочно. Минус такого бэкапа — восстановить возможно только в такую же версию PostgreSQL (отличаться может только патч релиз, третья цифра после точки в версии). 

Пример:

     pg_dump -Fc dbname > filename
	
Через psql такой бэкап не восстановить, но для этого есть утилита — pg_restore.

     pg_restore -d dbname filename

При слишком большой базе данных вариант с командой split нужно комбинировать со сжатием данных


#### 2. Создание backup на одном сервере и восстановление на другом

      pg_dump -h host1 db_name | psql -h host2 db_name
      pg_dump -h 192.168.122.100 db_name | psql -h 192.168.122.101 db_name
      
      Внимание: БД на втором сервере должна быть предварительно создана командой CREATE DATABASE
      
  
#### 3. Скрипты использующие pg_dump
