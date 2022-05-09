## Репликация

Цель:

На 1 ВМ создаем таблицы test для записи, test2 для запросов на чтение. Создаем публикацию таблицы test и подписываемся на публикацию таблицы test2 с ВМ №2. 

На 2 ВМ создаем таблицы test2 для записи, test для запросов на чтение. Создаем публикацию таблицы test2 и подписываемся на публикацию таблицы test1 с ВМ №1. 

3 ВМ использовать как реплику для чтения и бэкапов (подписаться на таблицы из ВМ №1 и №2 ). Небольшое описание, того, что получилось.

Реализовать горячее реплицирование для высокой доступности на 4ВМ. Источником должна выступать ВМ №3. Написать с какими проблемами столкнулись. (Задание со звездочкой).

### Настройка Postgresql на 3 ВМ.

На каждом кластере Postgresql каждой из трех BM выполняем:
1. в файле postgresql.conf следующие значения параметров:
        listen_addresses = '*'
        wal_level=logical
        
        
2. в файле pg_hba.conf добавляем строку:
host    all             all             0.0.0.0/0               scram-sha-256

3. пользователю postgres пресваиваем пароль postgres.

4. Перегружаем каждый кластер.


### Основные действия.

##### На ВМ 1 создаем БД logic_replication_01;
        postgres=# create database logic_replication_01;
        CREATE DATABASE

        postgres=# \l
                                            List of databases
                Name         |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
        ----------------------+----------+----------+-------------+-------------+-----------------------
        logic_replication_01 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
    
##### На ВМ 2 создаем БД logic_replication_02;

        postgres=# create database logic_replication_02;
        CREATE DATABASE
        postgres=# \l
                                            List of databases
                Name         |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
        ----------------------+----------+----------+-------------+-------------+-----------------------
        logic_replication_02 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 

##### На ВМ 3 создаем БД logic_replication_03;
    
        postgres=# create database logic_replication_03;
        CREATE DATABASE
        postgres=# \l
                                            List of databases
                 Name         |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
        ----------------------+----------+----------+-------------+-------------+-----------------------
         logic_replication_02 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |     

#### В БД logic_replication_01 ВМ 1 создаем 2 таблицы test1_students и test2_cites

        logic_replication_01=#  create table test1_students (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, first_name text, second_name text, email text);
        CREATE TABLE
        logic_replication_01=# create table test2_cites (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, city_name text, region text, country text);
        CREATE TABLE
#### Добавим 2 записи в таблицу test1_students для проверки возможности передачи существующих записей.

        logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Ivanov','Ivan','iivanov@gmail.com');
        INSERT 0 1
        logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Petrov','Peter','petrov@mail.ru');
        INSERT 0 1

#### В БД logic_replication_02 ВМ 2 создаем 2 таблицы test1_students и test2_cites.

        logic_replication_02=# create table test1_students (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, first_name text, second_name text, email text);
        CREATE TABLE
        logic_replication_02=# create table test2_cites (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, city_name text, region text, country text);
        CREATE TABLE
        
        
#### Включение логической репликации logic_replication_01.test1_students (поставщик) -> logic_replication_02.test1_students (подписчик)

##### В БД logic_replication_01 ВМ1 (поставщик):
        logic_replication_01=# CREATE PUBLICATION test1_pub FOR TABLE test1_students;
        CREATE PUBLICATION
        logic_replication_01=# \dRp+
                                Publication test1_pub
        Owner   | All tables | Inserts | Updates | Deletes | Truncates | Via root 
        ----------+------------+---------+---------+---------+-----------+----------
        postgres | f          | t       | t       | t       | t         | f
        Tables:
        "public.test1_students"

##### В БД logic_replication_02 ВМ2 (подпистик):   
        logic_replication_02=# CREATE SUBSCRIPTION test1_sub CONNECTION 'host=192.168.122.220 port=5432 user=postgres password=postgres dbname=logic_replication_01' PUBLICATION test1_pub WITH (copy_data=true);
        NOTICE:  created replication slot "test1_sub" on publisher
        CREATE SUBSCRIPTION
        logic_replication_02=# \dRs
                    List of subscriptions
        Name    |  Owner   | Enabled | Publication 
        -----------+----------+---------+-------------
        test1_sub | postgres | t       | {test1_pub}
        (1 row)

        logic_replication_02=# select * from test
        test1_students         test1_students_id_seq  test2_cites            test2_cites_id_seq     
        logic_replication_02=# select * from test1_students;
        id | first_name | second_name |       email       
        ----+------------+-------------+-------------------
        1 | Ivanov     | Ivan        | iivanov@gmail.com
        2 | Petrov     | Peter       | petrov@mail.ru
        (2 rows)

Данные таблицы test1_students  БД logic_replication_01 ВМ1 реплицировались в таблицу  test1_students  БД logic_replication_02 ВМ2 т.к. при создании репликации использовался параметр copy_data=true.

##### Проверка работы репликации.

    Добавление записи в таблицу test1_students  БД logic_replication_01 ВМ1
    logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Pupkin','Vasia','vpupkin@rambler.ru');
    INSERT 0 1
    
    logic_replication_01=# select * from test1_students;
    id | first_name | second_name |       email        
    ----+------------+-------------+--------------------
    1 | Ivanov     | Ivan        | iivanov@gmail.com
    2 | Petrov     | Peter       | petrov@mail.ru
    3 | Pupkin     | Vasia       | vpupkin@rambler.ru
    (3 rows)

    ПРоверяем наличие добавленной записи в test1_students  БД logic_replication_02 ВМ2
    
    logic_replication_02=# select * from test1_students;
    id | first_name | second_name |       email        
    ----+------------+-------------+--------------------
    1 | Ivanov     | Ivan        | iivanov@gmail.com
    2 | Petrov     | Peter       | petrov@mail.ru
    3 | Pupkin     | Vasia       | vpupkin@rambler.ru
    (3 rows)

Запись появилась.


#### Включение логической репликации logic_replication_02.test2_cites (поставщик) -> logic_replication_01.test2_cites (подписчик)

##### Перед включением репликации добавим 3 записи в таблицу  logic_replication_02.test2_cites и при настройки логической репликации отключаем параметр начальной синхронизации (copy_data=false)  
   
        logic_replication_02=# alter user postgres with password 'postgres';
        ALTER ROLE
        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Москва','Москва','Россия');
        INSERT 0 1
        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Киржач','Владимирская область','Россия');
        INSERT 0 1
        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Арсеньев','Приморский край','Россия');
        INSERT 0 1
        
        logic_replication_02=# select * from test2_cites;
        id | city_name |        region        | country 
        ----+-----------+----------------------+---------
        1 | Москва    | Москва               | Россия
        2 | Киржач    | Владимирская область | Россия
        3 | Арсеньев  | Приморский край      | Россия
        (3 rows)
  
##### В  БД logic_replication_02 ВМ2 (поставщик):
        logic_replication_02=# CREATE PUBLICATION test2_pub FOR TABLE test2_cites;
        CREATE PUBLICATION
        logic_replication_02=# \dRp+
                                Publication test2_pub
        Owner   | All tables | Inserts | Updates | Deletes | Truncates | Via root 
        ----------+------------+---------+---------+---------+-----------+----------
        postgres | f          | t       | t       | t       | t         | f
        Tables:
            "public.test2_cites"


##### В БД logic_replication_01 ВМ1 (подписчик):   
        logic_replication_01=# CREATE SUBSCRIPTION test2_sub CONNECTION 'host=192.168.122.221 port=5432 user=postgres password=postgres dbname=logic_replication_02' PUBLICATION test2_pub WITH (copy_data=false);
        NOTICE:  created replication slot "test2_sub" on publisher
        CREATE SUBSCRIPTION
        
        logic_replication_01=# select * from test2_cites;
        id | city_name | region | country 
        ----+-----------+--------+---------
        (0 rows)
      
таблица test2_cites logic_replication_01 ВМ1 пустая т.к. при создании данной логической репликации установлен параметр copy_data=false.

##### Проверка работы репликации:

Добавляем 2 записи в таблицу test2_cites БД logic_replication_02.

        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Лондон','','Англия');
        INSERT 0 1
        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Париж','','Франция');
        INSERT 0 1
        logic_replication_02=# select * from test2_cites;
        id | city_name |        region        | country 
        ----+-----------+----------------------+---------
        1 | Москва    | Москва               | Россия
        2 | Киржач    | Владимирская область | Россия
        3 | Арсеньев  | Приморский край      | Россия
        4 | Лондон    |                      | Англия
        5 | Париж     |                      | Франция
        (5 rows)

Проверяем таблицу test2_cites БД logic_replication_01.

        logic_replication_01=# select * from test2_cites;
        id | city_name | region | country 
        ----+-----------+--------+---------
        4 | Лондон    |        | Англия
        5 | Париж     |        | Франция
        (2 rows)

Видим что записи появились. Репликация работает.
#### Настройка подписчиков а БД logic_replication_03 ВМ3

##### В БД logic_replication_03 создаем 2 таблицы test1_students и test2_cites. 

        logic_replication_03=# create table test1_students (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, first_name text, second_name text, email text);
        CREATE TABLE
        logic_replication_03=# create table test2_cites (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, city_name text, region text, country text);
        CREATE TABLE

        logic_replication_03=# \dt
                    List of relations
        Schema |      Name      | Type  |  Owner   
        --------+----------------+-------+----------
        public | test1_cites    | table | postgres
        public | test2_students | table | postgres
        (2 rows)

##### Настройка подписчика test1_students БД logic_replication_03

        logic_replication_03=# CREATE SUBSCRIPTION test3_sub CONNECTION 'host=192.168.122.220 port=5432 user=postgres password=postgres     dbname=logic_replication_01' PUBLICATION test1_pub WITH (copy_data=true);
        NOTICE:  created replication slot "test3_sub" on publisher
        CREATE SUBSCRIPTION
        logic_replication_03=# \dRs
                    List of subscriptions
        Name    |  Owner   | Enabled | Publication 
        -----------+----------+---------+-------------
        test3_sub | postgres | t       | {test1_pub}
        (1 row)

##### Настройка подписчика test2_cites БД logic_replication_03

       logic_replication_03=#  CREATE SUBSCRIPTION test4_sub CONNECTION 'host=192.168.122.221 port=5432 user=postgres password=postgres dbname=logic_replication_02' PUBLICATION test2_pub WITH (copy_data=true);
       NOTICE:  created replication slot "test4_sub" on publisher
       CREATE SUBSCRIPTION
       
       logic_replication_03=# \dRs
                    List of subscriptions
        Name    |  Owner   | Enabled | Publication 
        -----------+----------+---------+-------------
        test3_sub | postgres | t       | {test1_pub}
        test4_sub | postgres | t       | {test2_pub}
        (2 rows)

       
##### Проверям наличие данных в таблицах test1_students и test2_cites БД logic_replication_03 ВМ3.

        logic_replication_03=# select * from test1_students;
        id | first_name | second_name |       email        
        ----+------------+-------------+--------------------
        1 | Ivanov     | Ivan        | iivanov@gmail.com
        2 | Petrov     | Peter       | petrov@mail.ru
        3 | Pupkin     | Vasia       | vpupkin@rambler.ru
        (3 rows)

        logic_replication_03=# select * from test2_cites;
        id | city_name |        region        | country 
        ----+-----------+----------------------+---------
        1 | Москва    | Москва               | Россия
        2 | Киржач    | Владимирская область | Россия
        3 | Арсеньев  | Приморский край      | Россия
        4 | Лондон    |                      | Англия
        5 | Париж     |                      | Франция
        (5 rows)

Видим что данные из таблицы test1_students БД logic_replication_01 ВМ1 и данные из таблицы test2_cites БД logic_replication_02 ВМ2 реплицировались в соответсвующие таблицы БД logic_replication_03 ВМ3      

##### Выполним дабавление строк в таблицу test1_students БД logic_replication_01 ВМ1 и в таблицу test2_cites БД logic_replication_02 ВМ2 и проверим что получилось.

##### Добавляем данные в таблицу test1_students БД logic_replication_01 ВМ1

        logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Sidorov','Sidor','sidor@gmail.ru');
        INSERT 0 1
        logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Кутозов','','kutuzov@gmail.ru');
        INSERT 0 1
        logic_replication_01=# 

##### Добавляем данные в таблицу test2_cites БД logic_replication_02 ВМ2

        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Новосибирск','Новосибирская обл','Россия');
        INSERT 0 1
        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Хабаровск','Приморский край','Россия');
        INSERT 0 1
        logic_replication_02=# 

##### Проверяем появление новых записей.

        logic_replication_03=# select * from test1_students;
        id | first_name | second_name |       email        
        ----+------------+-------------+--------------------
        1 | Ivanov     | Ivan        | iivanov@gmail.com
        2 | Petrov     | Peter       | petrov@mail.ru
        3 | Pupkin     | Vasia       | vpupkin@rambler.ru
        4 | Sidorov    | Sidor       | sidor@gmail.ru
        5 | Кутозов    |             | kutuzov@gmail.ru
        (5 rows)

        logic_replication_03=# select * from test2_cites;
        id |  city_name  |        region        | country 
        ----+-------------+----------------------+---------
        1 | Москва      | Москва               | Россия
        2 | Киржач      | Владимирская область | Россия
        3 | Арсеньев    | Приморский край      | Россия
        4 | Лондон      |                      | Англия
        5 | Париж       |                      | Франция
        6 | Новосибирск | Новосибирская обл    | Россия
        7 | Хабаровск   | Приморский край      | Россия
        (7 rows)

2 записи в таблице test1_students и 2 записи в таблице test2_cites реплицировались.

