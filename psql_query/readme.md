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

#### Работа с параметрами базы данных

#### Работа с pg_hba.conf

#### Работа со схемами

#### Работа с табличными пространствами

##### Просмотр какие БД используют табличное пространсва.

1. Определяем OID TAblespace которое хотит посмотреть.

        select oid, spcname,spcowner from pg_tablespace ;
        
        oid  |  spcname   | spcowner 
        -------+------------+----------
        1663 | pg_default |       10
        1664 | pg_global  |       10
       26172 | ts_01      |       10
       
       (3 строки)

2. Запромонимает OID Tablespace и определяем какие объекты каких БД есть в данном tablespace

    SELECT datname FROM pg_database WHERE OID IN (SELECT pg_tablespace_databases('26172'));
    
        datname  
        ----------
        test_db3
        (1 строка)

##### Удаление табличного пр-ва с объектами

#### Работа с таблицами

#### Работа с индексами

#### Работа с последовательностями

#### Работа с функциями

    \df - вывод списка доступных функций, которые есть в кластере Postgres


#### Работа с триггерами

    select tgname from pg_trigger; - вывод списка доступных триггеров в кластере Postgres

