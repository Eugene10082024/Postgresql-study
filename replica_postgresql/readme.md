## Репликация

Цель:

1. На 1 ВМ создаем таблицы test для записи, test2 для запросов на чтение. Создаем публикацию таблицы test и подписываемся на публикацию таблицы test2 с ВМ №2. 

2. На 2 ВМ создаем таблицы test2 для записи, test для запросов на чтение. Создаем публикацию таблицы test2 и подписываемся на публикацию таблицы test1 с ВМ №1. 

3. 3 ВМ использовать как реплику для чтения и бэкапов (подписаться на таблицы из ВМ №1 и №2 ). Небольшое описание, того, что получилось.

4. Реализовать горячее реплицирование для высокой доступности на 4ВМ. Источником должна выступать ВМ №3. Написать с какими проблемами столкнулись. (Задание со звездочкой).

### Настройка Postgresql на 3 ВМ.

На каждом кластере Postgresql каждой из трех BM выполняем:

1. в файле postgresql.conf следующие значения параметров:

        listen_addresses = '*'
        
        wal_level=logical
        
        
2. в файле pg_hba.conf добавляем строку:

        host    all             all             0.0.0.0/0               scram-sha-256

3. пользователю postgres пресваиваем пароль postgres.

4. Перегружаем каждый кластер.


#### Подготовительные действия.

##### На ВМ1 создаем БД logic_replication_01;
        postgres=# create database logic_replication_01;
        CREATE DATABASE

        postgres=# \l
                                            List of databases
                Name         |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
        ----------------------+----------+----------+-------------+-------------+-----------------------
        logic_replication_01 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
    
##### На ВМ2 создаем БД logic_replication_02;

        postgres=# create database logic_replication_02;
        CREATE DATABASE
        postgres=# \l
                                            List of databases
                Name         |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
        ----------------------+----------+----------+-------------+-------------+-----------------------
        logic_replication_02 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 

##### На ВМ3 создаем БД logic_replication_03;
    
        postgres=# create database logic_replication_03;
        CREATE DATABASE
        postgres=# \l
                                            List of databases
                 Name         |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
        ----------------------+----------+----------+-------------+-------------+-----------------------
         logic_replication_02 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |     

##### В БД logic_replication_01 ВМ1 создаем 2 таблицы test1_students и test2_cites

        logic_replication_01=#  create table test1_students (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, first_name text, second_name text, email text);
        CREATE TABLE
        logic_replication_01=# create table test2_cites (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, city_name text, region text, country text);
        CREATE TABLE
##### Добавим 2 записи в таблицу test1_students для проверки возможности передачи существующих записей.

        logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Ivanov','Ivan','iivanov@gmail.com');
        INSERT 0 1
        logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Petrov','Peter','petrov@mail.ru');
        INSERT 0 1

##### В БД logic_replication_02 ВМ2 создаем 2 таблицы test1_students и test2_cites.

        logic_replication_02=# create table test1_students (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, first_name text, second_name text, email text);
        CREATE TABLE
        logic_replication_02=# create table test2_cites (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, city_name text, region text, country text);
        CREATE TABLE
        
        
#### 1. Включение логической репликации logic_replication_01.test1_students (поставщик) -> logic_replication_02.test1_students (подписчик)

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


#### 2. Включение логической репликации logic_replication_02.test2_cites (поставщик) -> logic_replication_01.test2_cites (подписчик)

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
#### 3. Настройка подписчиков а БД logic_replication_03 ВМ3

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



### 4. Создание горячей реплики на ВМ4 с ВМ3.

#### Создаем ssh ключ для postgres на ВМ3 (192.168.122.222)

        postgres@ubuntu-20:~$ ssh-keygen -t rsa -P ""
        Generating public/private rsa key pair.
        Enter file in which to save the key (/var/lib/postgresql/.ssh/id_rsa): 
        Created directory '/var/lib/postgresql/.ssh'.
        Your identification has been saved in /var/lib/postgresql/.ssh/id_rsa
        Your public key has been saved in /var/lib/postgresql/.ssh/id_rsa.pub
        The key fingerprint is:
        SHA256:FbP+Yvsxq6lCErVqLapIJ5r96BSSxluGlv+AX3lwJa0 postgres@ubuntu-20.04-03
        The key's randomart image is:
        +---[RSA 3072]----+
        |          o      |
        |      . .  +     |
        |     . o oo      |
        |..o . . +o       |
        |o*.o = ES .      |
        |o.*.= *    .     |
        | =.* * .  o +    |
        |++=.+ o  . + +   |
        |=o+o.. ...+oo    |
        +----[SHA256]-----+

#### Копируем созданный ssh ключ с ВМ3 на ВМ4 (192.168.122.223)

        postgres@ubuntu-20:~$ ssh-copy-id -i ~/.ssh/id_rsa.pub postgres@localhost
        /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/var/lib/postgresql/.ssh/id_rsa.pub"
        /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
        /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
        postgres@localhost's password: 

        Number of key(s) added: 1

        Now try logging into the machine, with:   "ssh 'postgres@localhost'"
        and check to make sure that only the key(s) you wanted were added.


#### Создаем ssh ключ для postgres на ВМ4 (192.168.122.223)

        postgres@ubuntu-20:~$ ssh-keygen -t rsa
        Generating public/private rsa key pair.
        Enter file in which to save the key (/var/lib/postgresql/.ssh/id_rsa): 
        Enter passphrase (empty for no passphrase): 
        Enter same passphrase again: 
        Your identification has been saved in /var/lib/postgresql/.ssh/id_rsa
        Your public key has been saved in /var/lib/postgresql/.ssh/id_rsa.pub
        The key fingerprint is:
        SHA256:inJNRF5IL0Gjc4g3Vb6rxOGjWbjTApSOHeG+iGAT7FU postgres@ubuntu-20.04-04
        The key's randomart image is:
        +---[RSA 3072]----+
        |     oBoo        |
        |  .. E.*         |
        |...oB = o        |
        | o=o = . .       |
        |.*o.  o S        |
        |o+=  B o .       |
        |+.oo+.O .        |
        |o .oo*.o         |
        |    +o.          |
        +----[SHA256]-----+

#### Копируем созданный ssh ключ с ВМ4 на ВМ3 (192.168.122.222)

        postgres@ubuntu-20:~$ ssh-copy-id -i ~/.ssh/id_rsa.pub postgres@192.168.122.222
        /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/var/lib/postgresql/.ssh/id_rsa.pub"
        The authenticity of host '192.168.122.222 (192.168.122.222)' can't be established.
        ECDSA key fingerprint is SHA256:Sp4f5lESIrweTOtG4yMNdYuLOLVA4NOuNpUvUUigzZ8.
        Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
        /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
        /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
        postgres@192.168.122.222's password: 

        Number of key(s) added: 1

        Now try logging into the machine, with:   "ssh 'postgres@192.168.122.222'"
        and check to make sure that only the key(s) you wanted were added.



    
#### Редактируем pg_hba.conf на BM3 (192.168.122.222) и перечитываем файл pg_hba.conf

        host    replication     postgres        192.168.122.0/24        trust
    
        select pg_reload_conf();

#### Редактируем pg_hba.conf на BM3 (192.168.122.223) и перечитываем файл pg_hba.conf

        host    replication     postgres        192.168.122.0/24        trust
    
        select pg_reload_conf();
    
    
#### Проверяем и при необходимости изменяем параметры файла postgreesql.conf ВМ3

        listen_address = '*'
        wal_level = 'replica'
        wal_log_hits = on
        max_wal_sender = 2
        max_replication_slots = 1
        wal_keep_size = 100
        archive_mode = on
        log_line_prefix = '%m [%p]'
        hot_standby = on
    
#### Перезапускаем сервис postgresql на ВМ3

        root@ubuntu-20:~# pg_ctlcluster 14 main restart

    
#### Выполняем создание и запуск горячей реплики на ВМ4

##### Создаем каталог /var/lib/postgresql/14/backup

        root@ubuntu-20:~# mkdir /var/lib/postgresql/14/backup

##### Создаем резервную копию БД с ВМ 3 с помощью pg_basebackup

        root@ubuntu-20:~# pg_basebackup -h 192.168.122.222 -U postgres -p 5432 -D /var/lib/postgresql/14/backup -Fp -Xs -P -R

##### Останавиваем экземпляр postgresql

        root@ubuntu-20:~# pg_ctlcluster 14 main stop
        
##### Переопределяем владельца и права папки, в которую был сделал бэкап         

        root@ubuntu-20:~# chown -R postgres:postgres /var/lib/postgresql/14/backup
    
        root@ubuntu-20:~# chmod -R 700 /var/lib/postgresql/14/backup  
        
##### Переименовываем папку /var/lib/postgresql/14/main        

        root@ubuntu-20:~# mv /var/lib/postgresql/14/main /var/lib/postgresql/14/main-old

##### Переименовываем папку /var/lib/postgresql/14/backup

        root@ubuntu-20:~# mv /var/lib/postgresql/14/backup /var/lib/postgresql/14/main

##### Запускаем сервис postgresql

        root@ubuntu-20:~# pg_ctlcluster 14 main start

##### Проверяем работу реплики на BM4

root@ubuntu-20:~# ps aux | grep postgres
postgres   21968  0.1  0.9 2238732 78040 ?       Ss   22:06   0:00 /usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/14/main/postgresql.conf
postgres   21969  0.0  0.0 2238868 6112 ?        Ss   22:06   0:00 postgres: 14/main: startup recovering 000000010000000300000063
postgres   21970  0.0  0.0 2238732 6004 ?        Ss   22:06   0:00 postgres: 14/main: checkpointer 
postgres   21971  0.0  0.0 2238732 6024 ?        Ss   22:06   0:00 postgres: 14/main: background writer 
postgres   21972  0.0  0.0  73152  5456 ?        Ss   22:06   0:00 postgres: 14/main: stats collector 
postgres   21973  0.1  0.1 2239268 12756 ?       Ss   22:06   0:00 postgres: 14/main: walreceiver streaming 3/63000060
root       21985  0.0  0.0   9048   656 pts/0    S+   22:06   0:00 grep --color=auto postgres

postgres@ubuntu-20:~$ ps wuax | grep receiver
postgres   21973  0.0  0.1 2239268 12756 ?       Ss   22:06   0:00 postgres: 14/main: walreceiver streaming 3/63000148

##### Проверяем наличие данных на горячей реплике ВМ4.

        postgres@ubuntu-20:~$ psql
        psql (14.2 (Ubuntu 14.2-1.pgdg20.04+1+b1))
        Type "help" for help.

        postgres=# \l
                                            List of databases
                Name         |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
        ----------------------+----------+----------+-------------+-------------+-----------------------
        logic_replication_03 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
        postgres             | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
        template0            | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                             |          |          |             |             | postgres=CTc/postgres
        template1            | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                             |          |          |             |             | postgres=CTc/postgres
        (4 rows)

        postgres=# \c logic_replication_03 
        You are now connected to database "logic_replication_03" as user "postgres".
        logic_replication_03=# \dt
                    List of relations
        Schema |      Name      | Type  |  Owner   
        --------+----------------+-------+----------
        public | test1_students | table | postgres
        public | test2_cites    | table | postgres
        (2 rows)

        logic_replication_03=# 


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

        logic_replication_03=# 

Все данные доехали до горячей реплики.


#### Проверяем доставку данных с ВМ1 и ВМ2, через ВМ3 на горячую реплику ВМ4.

##### Выполним добавление данных в таблицу test1_students БД logic_replication_01 ВМ1

        logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Суворов','Александр','suvorov@ya.ru');
        INSERT 0 1
        logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Македонский','Александр','ma@rambler.ru');
        INSERT 0 1
        logic_replication_01=# INSERT INTO test1_students (first_name,second_name,email) VALUES ('Петр I','','peter@ya.ru');
        INSERT 0 1
        logic_replication_01=# 


        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Самара','Самарская область','Россия');
        INSERT 0 1
        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Саратов','Саратовская область','Россия');
        INSERT 0 1
        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Тула','Тульская область','Россия');
        INSERT 0 1
        logic_replication_02=# insert into test2_cites (city_name, region, country) VALUES ('Минск','','Белорусь');
        INSERT 0 1
        logic_replication_02=# 



##### Проверяем наличие введенных данных в БД ВМ 4.

        postgres@ubuntu-20:~$ hostname
        ubuntu-20.04-04
        postgres@ubuntu-20:~$ psql
        psql (14.2 (Ubuntu 14.2-1.pgdg20.04+1+b1))
        Type "help" for help.
        postgres=# \c logic_replication_03 
        You are now connected to database "logic_replication_03" as user "postgres".
        logic_replication_03=# select * from test1_students;
        id | first_name  | second_name |       email        
        ----+-------------+-------------+--------------------
        1 | Ivanov      | Ivan        | iivanov@gmail.com
        2 | Petrov      | Peter       | petrov@mail.ru
        3 | Pupkin      | Vasia       | vpupkin@rambler.ru
        4 | Sidorov     | Sidor       | sidor@gmail.ru
        5 | Кутозов     |             | kutuzov@gmail.ru
        6 | Суворов     | Александр   | suvorov@ya.ru
        7 | Македонский | Александр   | ma@rambler.ru
        8 | Петр I      |             | peter@ya.ru
        (8 rows)

        logic_replication_03=# select * from test2_cites;
        id |  city_name  |        region        | country  
        ---+-------------+----------------------+----------
        1  | Москва      | Москва               | Россия
        2  | Киржач      | Владимирская область | Россия
        3  | Арсеньев    | Приморский край      | Россия
        4  | Лондон      |                      | Англия
        5  | Париж       |                      | Франция
        6  | Новосибирск | Новосибирская обл    | Россия
        7  | Хабаровск   | Приморский край      | Россия
        8  | Самара      | Самарская область    | Россия
        9  | Саратов     | Саратовская область  | Россия
        10 | Тула        | Тульская область     | Россия
        11 | Минск       |                      | Белорусь
        (11 rows)


Логическая репликация на ВМ3 с последующей потоковой репликацией работает.






