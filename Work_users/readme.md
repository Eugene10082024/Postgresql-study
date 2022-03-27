### Работа с базами данных, пользователями и правами

### Цель:

создание новой базы данных, схемы и таблицы

создание роли для чтения данных из созданной схемы созданной базы данных

создание роли для чтения и записи из созданной схемы созданной базы данных

### Выполнение ДЗ

#### 1 создайте новый кластер PostgresSQL 14
Кластер поднят на ВМ c OC Ubuntu-20.04 в среде KVM 
#### 2 зайдите в созданный кластер под пользователем postgres

        postgres@ubuntu-20:~$ psql
        psql (14.2 (Ubuntu 14.2-1.pgdg20.04+1))
        Type "help" for help.

#### 3 создайте новую базу данных testdb

        postgres=# create database testdb;
        CREATE DATABASE
        postgres=# \l
                                        List of databases
           Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
        -----------+----------+----------+-------------+-------------+-----------------------
         postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
         template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                   |          |          |             |             | postgres=CTc/postgres
         template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                   |          |          |             |             | postgres=CTc/postgres
         testdb    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
        (4 rows)

#### 4 зайдите в созданную базу данных под пользователем postgres

        postgres=# \c testdb
        You are now connected to database "testdb" as user "postgres".
        testdb=# 

#### 5 создайте новую схему testnm

        testdb=# create schema testnm;
        CREATE SCHEMA
        testdb=# \dn
        List of schemas
        Name  |  Owner   
        --------+----------
        public | postgres
        testnm | postgres
        (2 rows)



#### 6 создайте новую таблицу t1 с одной колонкой c1 типа integer
        testdb=# create table t1 (c1 int);
        CREATE TABLE
        testdb=# \dt
                List of relations
        Schema | Name | Type  |  Owner   
        --------+------+-------+----------
        public | t1   | table | postgres
        (1 row)

#### 7 вставьте строку со значением c1=1
        testdb=# insert into t1 (c1) values (1);
        INSERT 0 1
        testdb=# select * from t1;
        c1 
        ----
        1
        (1 row)


#### 8 создайте новую роль readonly
        testdb=# create role readonly;
        CREATE ROLE
        testdb=# \du;
                                        List of roles
        Role name |                         Attributes                         | Member of 
        -----------+------------------------------------------------------------+-----------
        postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
        readonly  | Cannot login                                               | {}

        testdb=# 

#### 9 дайте новой роли право на подключение к базе данных testdb

        testdb=# grant connect on DATABASE testdb TO readonly;
        GRANT


####10 дайте новой роли право на использование схемы testnm

        testdb=# grant  usage on schema testnm to readonly;
        GRANT

#### 11 дайте новой роли право на select для всех таблиц схемы testnm
        
        testdb=# grant select on all tables in schema testnm to readonly;
        GRANT

#### 12 создайте пользователя testread с паролем test123

        testdb=# create user testread with password 'test123';
        CREATE ROLE
        testdb=# \du;
                                        List of roles
        Role name |                         Attributes                         | Member of 
        -----------+------------------------------------------------------------+-----------
        postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
        readonly  |                                                            | {}
        testread  |                                                            | {}



#### 13 дайте роль readonly пользователю testread

        testdb=# GRANT readonly to testread;
        GRANT ROLE

#### 14 зайдите под пользователем testread в базу данных testdb
        testdb=# \c testdb testread;
        connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  Peer authentication failed for user "testread"
        Previous connection kept
        testdb=# \q

        vi /etc/postgresql/14/main/pg_hba.conf 
        Вносим изменения в строку:
        local   all             all                                     scram-sha-256
        
        postgres@ubuntu-20:~$ psql
        psql (14.2 (Ubuntu 14.2-1.pgdg20.04+1))
        Type "help" for help.

        postgres=# select pg_reload_conf();
        pg_reload_conf 
        ----------------
        t
        (1 row)
      
        postgres=# \c testdb testread
        Password for user testread: 
        You are now connected to database "testdb" as user "testread".
        testdb=> select cur

        testdb=> select current_user;
        current_user 
        --------------
        testread
        (1 row)

####15 сделайте select * from t1;

        testdb=> select * from t1;
        ERROR:  permission denied for table t1
        testdb=> 


#### 16 получилось? (могло если вы делали сами не по шпаргалке и не упустили один существенный момент про который позже)

    Посмотреть данные в таблице t1 пользователем testread не получилось.

#### 17 что именно произошло в тексте домашнего задания
Таблица по умолчанию была создана в схеме public. (т.к. show search_path -> "$user", public)

        testdb=> \dt;
                List of relations
        Schema | Name | Type  |  Owner   
        --------+------+-------+----------
        public | t1   | table | postgres
        (1 row)
        
#### 18 у вас есть идеи почему? ведь права то дали?
Права роли readonly и пользозателю testread были даны в схеме testnm, а таблица создана в схеме public.
На данную таблицу права имеет только пользователь postgrres как superuser.

        testdb=# SELECT table_schema as schema, table_name as table, privilege_type as privilege FROM information_schema.table_privileges WHERE grantee='readonly';
        schema | table | privilege 
        --------+-------+-----------
        (0 rows)

        testdb=# SELECT table_schema as schema, table_name as table, privilege_type as privilege FROM information_schema.table_privileges WHERE grantee='testread';
        schema | table | privilege 
        --------+-------+-----------
        (0 rows)        
        
        
        testdb=# SELECT table_schema as schema, table_name as table, privilege_type as privilege FROM information_schema.table_privileges WHERE grantee='postgres';
        testdb=# 


            schema       |                 table                 | privilege  
        --------------------+---------------------------------------+------------
        public             | t1                                    | INSERT
        public             | t1                                    | SELECT
        public             | t1                                    | UPDATE
        public             | t1                                    | DELETE
        public             | t1                                    | TRUNCATE
        public             | t1                                    | REFERENCES
        public             | t1                                    | TRIGGER

 
Для того чтобы получить доступ пользоваетлем testread к таблице t1.

        Переносим таблицу t1 d схему testnm:
        testdb=# \c testdb postgres
        You are now connected to database "testdb" as user "postgres".
        testdb=# alter table t1 SET SCHEMA testnm;
        ALTER TABLE
        
        testdb=# grant  usage on schema testnm to readonly;
        GRANT
        testdb=# grant select on all tables in schema testnm to readonly;
        GRANT
        
        testdb=# \c testdb testread;
        Password for user testread: 
        You are now connected to database "testdb" as user "testread".
        testdb=> select * from testnm.t1;
        c1 
        ----
        1
        (1 row)
        
Получили доступ пользователем testread к таблице t1       

Также можно пользоватлю testread на схему public и можно будет также просматривать таблицу t1

#### 22 вернитесь в базу данных testdb под пользователем postgres

        testdb=> \c testdb postgres;
        You are now connected to database "testdb" as user "postgres".


#### 23 удалите таблицу t1

        testdb=# drop table t1;
        DROP TABLE


#### 24 создайте ее заново но уже с явным указанием имени схемы testnm

        testdb=# create table testnm.t1 (c1 int);
        CREATE TABLE
        
        testdb=# \dt testnm.t1;
                List of relations
        Schema | Name | Type  |  Owner   
        --------+------+-------+----------
        testnm | t1   | table | postgres


#### 25 вставьте строку со значением c1=2

        testdb=# insert into testnm.t1 (c1) values (2);
        INSERT 0 1

#### 26 зайдите под пользователем testread в базу данных testdb

        testdb=# \c testdb testread;
        Password for user testread: 
        You are now connected to database "testdb" as user "testread".
        testdb=> 

#### 27 сделайте select * from testnm.t1;

        testdb=> select * from testnm.t1;
        ERROR:  permission denied for table t1
        testdb=> 

#### 28 получилось?

        ERROR:  permission denied for table t1
        
29 есть идеи почему? если нет - смотрите шпаргалку
На вновь создаваемие объекты у роkb readonly и соответственно пользователя testread прав нет.
Для того чтобы можно было просмотреть данные из таблицы t1 пользователем testread делаем следующее:

        testdb=> \c testdb postgres;
        You are now connected to database "testdb" as user "postgres".

        testdb=# grant select on all tables in schema testnm to readonly;
        GRANT

        testdb=# \c testdb testread;
        Password for user testread: 
        You are now connected to database "testdb" as user "testread".

        testdb=> select * from testnm.t1;
        c1 
        ----
        2
        (1 row)

#### 30 как сделать так чтобы такое больше не повторялось? 
Для того чтобы были права на вновь создаваемые объекты в схеме делаем:

        testdb=> \c testdb postgres;
        You are now connected to database "testdb" as user "postgres".       
        ALTER default privileges in SCHEMA testnm grant SELECT on TABLEs to readonly; 
        
        testdb=# ALTER default privileges in SCHEMA testnm grant SELECT on TABLEs to readonly; 
        ALTER DEFAULT PRIVILEGES

        testdb=# create table testnm.t2 (c1 int);
        CREATE TABLE

        testdb=# insert into testnm.t2 (c1) values (1);
        INSERT 0 1
        
        testdb=# \c testdb testread;
        Password for user testread: 
        You are now connected to database "testdb" as user "testread".
        
        testdb=> select * from testnm.t2;
        c1 
        ----
        1
        (1 row)


#### 34 теперь попробуйте выполнить команду create table t2(c1 integer); insert into t2 values (2);

        testdb=> create table t2 (c1 int);
        CREATE TABLE

        testdb=> \dt
                List of relations
        Schema | Name | Type  |  Owner   
        --------+------+-------+----------
        public | t2   | table | testread
        (1 row)

        testdb=> insert into t2 (c1) values (3);
        INSERT 0 1
        
        testdb=> select * from t2;
        c1 
        ----
        3
        (1 row)

#### 35 а как так? нам же никто прав на создание таблиц и insert в них под ролью readonly?

По умолчанию все имеют права CREATE и USAGE в схеме public. Благодаря этому все пользователи могут подключаться к заданной базе данных и создавать объекты в её схеме public.

#### 36 есть идеи как убрать эти права? 
Для того чтобы убрать данные права необходимо выполнить команду:

    REVOKE CREATE ON SCHEMA public FROM PUBLIC;

Первое слово «public» обозначает схему, а второе означает «каждый пользователь»
Проверяем:

        testdb=> \c testdb postgres;
        You are now connected to database "testdb" as user "postgres".   
        
        testdb=# REVOKE CREATE ON SCHEMA public FROM PUBLIC;
        REVOKE
        
        testdb=# \c testdb testread;
        Password for user testread: 
        You are now connected to database "testdb" as user "testread".
        
        testdb=> create table t3 (c1 int);
        ERROR:  permission denied for schema public
        LINE 1: create table t3 (c1 int);
                     ^
Теперь ни один пользователей, кроме superuser не сможет создать объекты в схеме public по умолчанию.  


Один раз заглянул в шпаргалку по п.16 т.к. не внимательно прочилал мануал по Postgresql в части схемы public. Дальше прошел самостоятельно. По времени заняло около 2,5 ч. Читал мануал Postgresql чтобы выполнить действия. 
Мне понравилось. Спасибо

