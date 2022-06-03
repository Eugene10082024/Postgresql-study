### Запросы для работы с Postgresql 
[1. База данных](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-базой-данных)

[2. Параметры базы данных](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-Параметрами-базы-данных)

[2.pg_hba.conf](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-pg_hba.conf)

[3. Схемы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-со-схемами)

[4. Табличные пространства](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-табличными-пространствами)

[5. Таблицы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-таблицами)

[6. Индексы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-индексами)

[7. Последовательности](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-последовательностями)

[8. Функции](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-функциями)

[9. Триггеры](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-триггерами)

#### Работа с базой данных



При создании БД мы можем указать табличное пр-во по умолчанию:

            CREATE DATABASE <name_db> TABLESPACE <name_ts>;
 
В таком случае все объекты БД будут создаваться в указанном Tablespace

#### Работа с параметрами базы данных

#### Работа с pg_hba.conf

#### Работа со схемами

#### Работа с табличными пространствами

##### Создание табличного пространства
1. Создаем каталог в операционной системе:
        
        mkdir /mnt/postgres/ts_dir
  
2. Делаем владельцем каталога postgres

        chown -R postgres:postgres /mnt/postgres/ts_dir

3. Заходим в psql и создаем табличное пространство

        CREATE TABLESPACE ts LOCATION '/mnt/postgres/ts_dir';
        
 
##### Перенос объект из одного tablespace в другое:

        ALTER TABLE <name_table> SET TABLESPACE pg_default;
    
В данном случае объект перенесется в новое табличное пространство.

ВНИМАНИЕ:
При смене табличного пространства OID объекта остается старым, а имя файла объекта в новом табличном пространстве будет новое.

Определить его можно в pg_class.

        SELECT oid,relname,relfilenode from pg_class where relname='<name>';

relfilenode - текущие имя файла объекта.
При создании объекта oid = relfilenode

##### Перемещение всех таблиц из табличного пространства pg_default в new_ts

        ALTER TABLE ALL IN TABLESPACE pg_default SET TABLESPACE new_ts ; 
        
##### Просмотр какие БД используют табличное пространсва.

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
 
##### Удаление табличного пространства

           DROP TABLESPACE new_ts CASCADE 

[Удаление табличного пр-ва с объектами](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/tbs/drop_tablespace.md)

#### Работа с таблицами

#### Работа с индексами

#### Работа с последовательностями

#### Работа с функциями

    \df - вывод списка доступных функций, которые есть в кластере Postgres


#### Работа с триггерами

    select tgname from pg_trigger; - вывод списка доступных триггеров в кластере Postgres

