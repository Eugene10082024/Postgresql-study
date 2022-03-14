## Установка Postgresql

### Цель:

установить PostgreSQL в Docker контейнере. Выполняется установка Postgresql 14. Данные хранятся на ВМ. Точка монитрования - /mnt/postgresql/data

настроить контейнер для внешнего подключения


### 1. Установка и настройка сервиса docker

#### 1.1. Для того чтобы не набирать sudo повышаем права до root

        asarafanov@ubuntu-01:~$ sudo -i

#### 1.2. Устанавливаю дополнительные пакты, которые могут пригадиться для работы 

        root@ubuntu-01:~# apt install apt-transport-https ca-certificates curl software-properties-common

#### 1.3. Скачиваю и устанавливаю ключ для repo docker 

        root@ubuntu-01:~# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        OK

#### 1.4. Добавляем ссылку в на репозиторий docker в файл /etc/apt/sources.list

        root@ubuntu-01:~#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

#### 1.5. Выполняем установку сервиса docker

        root@ubuntu-01:~# apt install docker-ce

#### 1.6. Проверяем сервис docker жив или нет.

        root@ubuntu-01:~# systemctl status docker
        ● docker.service - Docker Application Container Engine
            Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
            Active: active (running) since Sat 2022-03-12 11:50:12 MSK; 16s ago
        TriggeredBy: ● docker.socket
            Docs: https://docs.docker.com
        Main PID: 3169 (dockerd)
            Tasks: 9
            Memory: 27.9M
            CGroup: /system.slice/docker.service
                    └─3169 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

#### 1.7. Добавляем свою учетную запись в группу docker чтобы при работе не использовать sudo. Для применения перелогиниваемся к серверу.
        root@ubuntu-01:~# usermod -aG docker asarafanov
        root@ubuntu-01:~# logout

#### 1.8. Проверяю в каких группах состоит моя учетная запись

        asarafanov@ubuntu-01:~$ id -Gn
        asarafanov adm cdrom sudo dip plugdev lpadmin lxd sambashare docker

### 2. Работа (установка, настройка,проверка) с docker cluster postgresql (server) 

#### 2.1. Созданию каталог на ВМ для хранения данных кластера Postgresql

        asarafanov@ubuntu-01:~$ sudo mkdir -p /mnt/postgresql/data
        
#### 2.2. Созданию сеть для работы dkockers

        asarafanov@ubuntu-01:~$ docker network create doc-net
        0b91d922e3a3e7681e7d2c0223cdd2aee4c5d0cea0157cf99e02684bdc045911

#### 2.3. Разварачиваю и запускаю docker кластера postgresql. Имя docker -  postgres-docker

        asarafanov@ubuntu-01:~$ docker run --postgres-docker --network doc-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /mnt/postgresql/data:/var/lib/postgresql/data postgres:14
        unknown flag: --postgres-docker
        
        See 'docker run --help'.
        asarafanov@ubuntu-01:~$ docker run --name postgres-docker --network doc-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /mnt/postgresql/data:/var/lib/postgresql/data postgres:14
        Unable to find image 'postgres:14' locally
        14: Pulling from library/postgres
        f7a1c6dad281: Pull complete 
        77c22623b5a6: Pull complete 
        0f6a6a85d014: Pull complete 
        6012728e8256: Pull complete 
        1eca9143e721: Pull complete 
        ab9ebd05a23f: Pull complete 
        16e63bb90eff: Pull complete 
        4c15c24115ca: Pull complete 
        bd2e23488f57: Pull complete 
        e3f1e9b8214b: Pull complete 
        fb40207b2190: Pull complete 
        fee65e0cfe12: Pull complete 
        7fae365c5301: Pull complete 
        Digest: sha256:768bd1d79ef01854ab12ba86a3dfe67baf30b205c7eef79e55b3fb39e391787e
        Status: Downloaded newer image for postgres:14
        350a69a0098bd47cb4d3a37732504a6cfc2f27b96d73c3306a6725ab3e69ee51

#### 2.4. Проверяю наличие запущенного docker.        

        asarafanov@ubuntu-01:~$ docker ps
        CONTAINER ID   IMAGE         COMMAND                  CREATED              STATUS              PORTS                                       NAMES
        350a69a0098b   postgres:14   "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-docker

        Docker Postgres-docker запущен.
        
#### 2.5. Проверяю наличие файлов кластера postgresql (Postgres-docker) в созданном каталоге ВМ
        asarafanov@ubuntu-01:~$ sudo ls -al /mnt/postgresql/data/
        total 136
        drwx------ 19 systemd-coredump root              4096 мар 12 12:26 .
        drwxr-xr-x  3 root             root              4096 мар 12 12:25 ..
        drwx------  5 systemd-coredump systemd-coredump  4096 мар 12 12:26 base
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:27 global
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_commit_ts
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_dynshmem
        -rw-------  1 systemd-coredump systemd-coredump  4821 мар 12 12:26 pg_hba.conf
        -rw-------  1 systemd-coredump systemd-coredump  1636 мар 12 12:26 pg_ident.conf
        drwx------  4 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_logical
        drwx------  4 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_multixact
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_notify
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_replslot
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_serial
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_snapshots
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_stat
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:28 pg_stat_tmp
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_subtrans
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_tblspc
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_twophase
        -rw-------  1 systemd-coredump systemd-coredump     3 мар 12 12:26 PG_VERSION
        drwx------  3 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_wal
        drwx------  2 systemd-coredump systemd-coredump  4096 мар 12 12:26 pg_xact
        -rw-------  1 systemd-coredump systemd-coredump    88 мар 12 12:26 postgresql.auto.conf
        -rw-------  1 systemd-coredump systemd-coredump 28835 мар 12 12:26 postgresql.conf
        -rw-------  1 systemd-coredump systemd-coredump    36 мар 12 12:26 postmaster.opts
        -rw-------  1 systemd-coredump systemd-coredump    94 мар 12 12:26 postmaster.pid


#### 2.6. Проверяю работу кластера Postgresql развернутого в docker.

Проверка выполняется с ВМ (IP - 192.168.122.150). IP ВМ где развернут docker - 192.168.122.171

#### 2.6.1. Подключаемся к ВМ (IP - 192.168.122.150) по ssh.

        asarafanov-adm@pc-asarafanov-01:~$ ssh asarafanov@192.168.122.150
        asarafanov@192.168.122.150's password: 
        Last login: Fri Mar 11 07:48:40 2022 from 192.168.122.1
        asarafanov@astra-postgres-01:~$ sudo -i
        root@astra-postgres-01:~# su - postgres

#### 2.6.2. Удаленно подключается к кластеру Postgresql c помощью утилиты psql

В кластере создаем: БД - study_otus_01, study_otus_02 и роль - student с возможностью подключения.


        postgres@astra-postgres-01:~$ psql -h 192.168.122.171 -d postgres -p 5432 -U postgres
        Пароль пользователя postgres: 
        psql (14.2)
        Введите "help", чтобы получить справку.

        postgres@postgres=# \l
                                        Список баз данных
            Имя    | Владелец | Кодировка | LC_COLLATE |  LC_CTYPE  |     Права доступа     
        -----------+----------+-----------+------------+------------+-----------------------
        postgres  | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
        template0 | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres          +
                  |          |           |            |            | postgres=CTc/postgres
        template1 | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres          +
                  |          |           |            |            | postgres=CTc/postgres
        (3 строки)

        postgres@postgres=# create database study_otus_01;
        CREATE DATABASE
        postgres@postgres=# create database study_otus_02;
        CREATE DATABASE
        postgres@postgres=# creatle role student with login;
        ERROR:  syntax error at or near "creatle"
        СТРОКА 1: creatle role student with login;
                ^
        postgres@postgres=# creatle role student login;
        ERROR:  syntax error at or near "creatle"
        СТРОКА 1: creatle role student login;
                ^
        postgres@postgres=# create role student login;
        CREATE ROLE
        postgres@postgres=# \l
                                        Список баз данных
            Имя      | Владелец | Кодировка | LC_COLLATE |  LC_CTYPE  |     Права доступа     
        ---------------+----------+-----------+------------+------------+-----------------------
        postgres      | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
        study_otus_01 | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
        study_otus_02 | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
        template0     | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres          +
                      |          |           |            |            | postgres=CTc/postgres
        template1     | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres          +
                      |          |           |            |            | postgres=CTc/postgres
        (5 строк) 

        postgres@postgres=# \du
                                                Список ролей
        Имя роли |                                Атрибуты                                 | Член ролей 
        ----------+-------------------------------------------------------------------------+------------
        postgres | Суперпользователь, Создаёт роли, Создаёт БД, Репликация, Пропускать RLS | {}
        student  |                                                                         | {}

        postgres@postgres=# 

Отключаемся от кластера Postgresql работающего в docker на ВМ 192.168.122.171

        postgres@postgres=# \q
        postgres@astra-postgres-01:~$ 

        
### 3. Работа (установка, настройка,проверка) с docker client postgresql        

#### 3.1. Подключается к кластеру postgresql через docker pg-client

        root@ubuntu-01:~# sudo docker run -it --rm --network doc-net --name pg-client postgres:14 psql -h postgres-docker -U postgres
        Password for user postgres: 
        psql (14.2 (Debian 14.2-1.pgdg110+1))
        Type "help" for help.

        postgres=# 

#### 3.2 Проверяем наличие созданных БД и роли. Све на месте.

        postgres=# \l
                                        List of databases
            Name      |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
        ---------------+----------+----------+------------+------------+-----------------------
        postgres      | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
        study_otus_01 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
        study_otus_02 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
        template0     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                      |          |          |            |            | postgres=CTc/postgres
        template1     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                      |          |          |            |            | postgres=CTc/postgres
        (5 rows)

        postgres=# \du
                                        List of roles
        Role name |                         Attributes                         | Member of 
        -----------+------------------------------------------------------------+-----------
        postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
        student   |                                                            | {}

        postgres=# 

#### 3.3. Создаем таблицу в БД study_otus_01 и добавляем пару строк.

        postgres=# \c study_otus_01 
        You are now connected to database "study_otus_01" as user "postgres".
        
        study_otus_01=# CREATE TABLE tb_users(user_id SERIAL PRIMARY KEY NOT NULL, username varchar(50) NOT NULL,email varchar(50) NOT NULL);
        CREATE TABLE
        
        study_otus_01=# INSERT INTO tb_users (username, email) VALUES ('Пупкин Василий','pypkin@gmail.com'), ('Иванов Иван','ivanov@ya.ru');
        INSERT 0 2
        
        study_otus_01=# SELECT * from tb_users;
        user_id |    username    |      email       
        --------+----------------+------------------
              1 | Пупкин Василий | pypkin@gmail.com
              2 | Иванов Иван    | ivanov@ya.ru
        (2 rows)

В БД study_otus_01 создана таблица tb_users и добавлены 2 записи.

Выходим из docker psql

        root@ubuntu-01:~# sudo docker ps -a
        CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS                                       NAMES
        30f0696c7e63   postgres:14   "docker-entrypoint.s…"   39 minutes ago   Up 39 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-docker

На ВМ запущен один докер с кластером postgresql.


#### 3.4. Подключение к кластеру с ВМ (IP - 192.168.122.150)

        postgres@astra-postgres-01:~$ ip addr
        1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
            link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
            inet 127.0.0.1/8 scope host lo
            valid_lft forever preferred_lft forever
            inet6 ::1/128 scope host 
            valid_lft forever preferred_lft forever
        2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
            link/ether 52:54:00:ae:ae:a9 brd ff:ff:ff:ff:ff:ff
            inet 192.168.122.150/24 brd 192.168.122.255 scope global noprefixroute eth0
            valid_lft forever preferred_lft forever
            inet6 fe80::ae85:c031:38ac:3961/64 scope link noprefixroute 
            valid_lft forever preferred_lft forever

        postgres@astra-postgres-01:~$ psql -h 192.168.122.171 -d postgres -p 5432 -U postgres
        Пароль пользователя postgres: 
        psql (14.2)
        Введите "help", чтобы получить справку.

        postgres@postgres=# \l
                                        Список баз данных
            Имя      | Владелец | Кодировка | LC_COLLATE |  LC_CTYPE  |     Права доступа     
        ---------------+----------+-----------+------------+------------+-----------------------
        postgres      | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
        study_otus_01 | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
        study_otus_02 | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
        template0     | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres          +
                    |          |           |            |            | postgres=CTc/postgres
        template1     | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres          +
                    |          |           |            |            | postgres=CTc/postgres
        (5 строк)

        postgres@postgres=# \c study_otus_01 
        Вы подключены к базе данных "study_otus_01" как пользователь "postgres".
        postgres@study_otus_01=# \dt
                    Список отношений
        Схема  |   Имя    |   Тип   | Владелец 
        --------+----------+---------+----------
        public | tb_users | таблица | postgres
        (1 строка)

        postgres@study_otus_01=# select * from tb_users;
        user_id |    username    |      email       
        ---------+----------------+------------------
            1 | Пупкин Василий | pypkin@gmail.com
            2 | Иванов Иван    | ivanov@ya.ru
        (2 строки)

        postgres@study_otus_01=# 

В кластере видем БД, созданную таблицу и 2 записи.


### 4. Удаление и создание контейнера сервера postgresql. Проверка наличия данных.

#### 4.1. Удаление контейнера с сервером postgresql.

        root@ubuntu-01:~# sudo docker ps -a
        CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                      PORTS     NAMES
        30f0696c7e63   postgres:14   "docker-entrypoint.s…"   49 minutes ago   Exited (0) 55 seconds ago             postgres-docker
        root@ubuntu-01:~# sudo docker stop 30f0696c7e63
        30f0696c7e63

        root@ubuntu-01:~# sudo docker rm 30f0696c7e63
        30f0696c7e63
        
        root@ubuntu-01:~# sudo docker ps -a
        CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
        root@ubuntu-01:~# 

#### 4.2. Создание контейнера с сервером postgresql.

        root@ubuntu-01:~# docker run --name postgres-docker --network doc-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /mnt/postgresql/data:/var/lib/postgresql/data postgres:14
        d0ba18d5cf3997e302edb13e0d7de72effca6daece3e82eeec7b3095f33bcf94
        root@ubuntu-01:~# docker ps -a
        CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS                                       NAMES
        d0ba18d5cf39   postgres:14   "docker-entrypoint.s…"   15 seconds ago   Up 14 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-docker

#### 4.3. Подключение к контейнеру сервера postgresql контейнером клиента psql        

        root@ubuntu-01:~# docker run -it --rm --network doc-net --name pg-client postgres:14 psql -h postgres-docker -U postgres
        Password for user postgres: 
        psql (14.2 (Debian 14.2-1.pgdg110+1))
        Type "help" for help.


#### 4.4. Проверка наличия данных сосданных ранее.

        postgres=# \l
                                        List of databases
            Name      |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
        ---------------+----------+----------+------------+------------+-----------------------
        postgres      | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
        study_otus_01 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
        study_otus_02 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
        template0     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                    |          |          |            |            | postgres=CTc/postgres
        template1     | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                    |          |          |            |            | postgres=CTc/postgres
        (5 rows)

        postgres=# \c study_otus_01 
        You are now connected to database "study_otus_01" as user "postgres".
        study_otus_01=# select * from tb_users;
        user_id |    username    |      email       
        ---------+----------------+------------------
            1 | Пупкин Василий | pypkin@gmail.com
            2 | Иванов Иван    | ivanov@ya.ru
        (2 rows)

        study_otus_01=# 

Все данные на месте.


