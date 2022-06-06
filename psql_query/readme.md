### Запросы для работы с Postgresql 
[1. База данных](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/tables/tables.md)

[2. Параметры базы данных](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/parameters/param.md)

[3. pg_hba.conf](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/pg_hba/pg_hba.md)

[4. Схемы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-со-схемами)

[5. Табличные пространства](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/tbs/tablespace.md)

  [Удаление табличного пр-ва с объектами](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/tbs/drop_tablespace.md)

[5. Таблицы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-таблицами)

[6. Секционированные таблицы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-секционированными-таблицами)

[7. Индексы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-индексами)

[8. Последовательности](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-последовательностями)

[9. Функции](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-функциями)

[10. Триггеры](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-триггерами)



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
##### Создание таблицы
            CREATE TABLE
Примеры:
##### Изменение свойств таблицы
            ALTER TABLE <name_table> SET SCHEMA <name_schema> ; - перемещение данных не происходит, изменения происходит в системном каталоге
            ALTER TABLE <name_table> SET tablespace <name_ts>; - Происходит физическое перемещение данных. Это требует иксклюзивной блокировки таблицы

##### Удаление таблицы
            DROP TABLE
               
##### Временные таблицы

1. Временные таблицы автоматически удаляются в конце сеанса или могут удаляться в конце текущей транзакции

2. Временные таблицы создаются в специальной схеме, так что при создании таких таблиц имя схемы задать нельзя

3. Для временных таблиц можно задать параметр ON COMMIT
 
Возможные значения:
     
  PRESERVE ROWS - никакие действия по завершении транзакции не выполняются (по умолчанию)
        
  DELETE ROWS   - при фиксации или отмене транзакции таблица очищается
        
  DROP          - при фиксации или отмене транзакции таблица удаляется 
  
  
#### Работа с секционированными таблицами

#### Работа с индексами

#### Работа с последовательностями

#### Работа с функциями

    \df - вывод списка доступных функций, которые есть в кластере Postgres


#### Работа с триггерами

    select tgname from pg_trigger; - вывод списка доступных триггеров в кластере Postgres

