### Работа с табличными пространствами

Объекты одной базы данных могут быть размещены в нескольких табличных пространствах.
В одном табличном пространстве могут быть размещены объекты нескольких баз данных.

При установке кластера создаются два табличных пространства. 

**pg_default** - используется по умолчанию при создании объектов БД (если не было задано другое ТС по умолчанию). Распологается в каталоге PGDATA/base, внутри этого каталога объекты размещаются в подкаталогах баз данных




#### Создание табличного пространства
1. Создаем каталог в операционной системе:
        
        mkdir /mnt/postgres/ts_dir
  
2. Делаем владельцем каталога postgres

        chown -R postgres:postgres /mnt/postgres/ts_dir

3. Заходим в psql и создаем табличное пространство

        CREATE TABLESPACE ts LOCATION '/mnt/postgres/ts_dir';
        
 
#### Перенос объект из одного tablespace в другое:

        ALTER TABLE <name_table> SET TABLESPACE pg_default;
        
#### Просмотр местнонахождения табличного пространства.

        \db+

        select spcname ,pg_tablespace_location(oid) from pg_tablespace;
          spcname   | pg_tablespace_location
        ------------+------------------------
         pg_default |
         pg_global  |
        (2 rows)

    
В данном случае объект перенесется в новое табличное пространство.

##### ВНИМАНИЕ:

При смене табличного пространства OID объекта остается старым, а имя файла объекта в новом табличном пространстве будет новое.

Определить его можно в pg_class.

        SELECT oid,relname,relfilenode from pg_class where relname='<name>';

relfilenode - текущие имя файла объекта.
При создании объекта oid = relfilenode

#### Перемещение всех таблиц из табличного пространства pg_default в new_ts

        ALTER TABLE ALL IN TABLESPACE pg_default SET TABLESPACE new_ts ; 
        
#### Просмотр какие БД используют табличное пространсва.

1. Определяем OID TAblespace которое хотит посмотреть.

        SELECT oid, spcname,spcowner FROM pg_tablespace ;
        
        oid  |  spcname   | spcowner 
        -------+------------+----------
        1663 | pg_default |       10
        1664 | pg_global  |       10
       26172 | ts_01      |       10
       
       (3 строки)

2. Запомонимает OID Tablespace и определяем какие объекты каких БД есть в данном tablespace

             SELECT datname FROM pg_database WHERE OID IN (SELECT pg_tablespace_databases('26172'));
                     datname  
                    ----------
                    test_db3
                    (1 строка)
 
#### Удаление табличного пространства

           DROP TABLESPACE new_ts CASCADE 
           
           
### Дополнительная информация:

[Удаление табличного пространства с объектами](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/tbs/drop_tablespace.md)
