### Установка и настройка PostgreSQL

### Цель:
создавать дополнительный диск для уже существующей виртуальной машины, размечать его и делать на нем файловую систему

переносить содержимое базы данных PostgreSQL на дополнительный диск

переносить содержимое БД PostgreSQL между виртуальными машинами

### Выполнение ДЗ.

#### Установка кластера postgresql 14 на Ubuntu-20-01 (IP 192.168.122.180)

##### Создание файла репозитория:

        sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

#### Импортирование ключа репозитория:

        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

####  Обновление списка пакетов:

        apt-get update

#### Установка Postgresql 14.2.

        apt-get -y install postgresql-14

#### Проверка установленного кластера Postgresql на ВМ

        asarafanov@ubuntu-20:~$ sudo -u postgres pg_lsclusters 
        Ver Cluster Port Status Owner    Data directory              Log file
        14  main    5432 online postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log

Кластер Postgresql-14 установлен и запущен.

### Создание БД, таблицы и добавление строк в таблицу 

#### Подключение к кластеру postgresql с помощью psql

        postgres@ubuntu-20:~$ psql
        psql (14.2 (Ubuntu 14.2-1.pgdg20.04+1))
        Type "help" for help.

#### Создание БД test.

        postgres=# create database test;
        CREATE DATABASE

#### Создание таблицы test в БД test        
        postgres=# \c test;
        You are now connected to database "test" as user "postgres".
        test=# create table test(id serial, name1 text);
        CREATE TABLE

#### Добавление строк в таблицу test

        test=# insert into test (name1) Values ('Pupkin Vasia');
        INSERT 0 1
        test=# insert into test (name1) Values ('Ivanov Ivan');
        INSERT 0 1
        test=# insert into test (name1) Values ('Petrov Petr');
        INSERT 0 1
        
#### Проверка наличия записей в таблице test

        test=# select * from test;
        id |    name1     
        ----+--------------
        1 | Pupkin Vasia
        2 | Ivanov Ivan
        3 | Petrov Petr
        (3 rows)

### Добавлние нового диска к ВМ, инициализация диска и монтирование к точке монтирования /mnt/disk_01

Все операции делаем под пользователем root

#### Проверка наличия нового блочного устройства презентованного гипервизером KVM.

        root@ubuntu-20:~# lsblk
        NAME                MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
        sda                   8:0    0    20G  0 disk 
        ├─sda1                8:1    0   512M  0 part /boot/efi
        ├─sda2                8:2    0     1K  0 part 
        └─sda5                8:5    0  19,5G  0 part 
        ├─vgubuntu-root   253:0    0  18,5G  0 lvm  /
        └─vgubuntu-swap_1 253:1    0   976M  0 lvm  [SWAP]
        vda                 252:0    0    20G  0 disk 

Новое устройсво vda презентовано.

#### Инициализация устройства vda с помощью утилиты Parted

        root@ubuntu-20:~# parted /dev/vda
        GNU Parted 3.3
        Using /dev/vda
            (parted) mktable                                                          
            New disk label type? gpt                                                  
            (parted) mkpart                                                           
            Partition name?  []?                                                      
            File system type?  [ext2]? ext4                                           
            Start? 0%                                                                 
            End? 100%                                                                 
        (parted) quit                                               


        root@ubuntu-20:~# mkfs.ext4 /dev/vda1                                     
        mke2fs 1.45.5 (07-Jan-2020)
        Creating filesystem with 5242368 4k blocks and 1310720 inodes
        Filesystem UUID: d8ecb68d-7928-4774-938c-a88bf3e85dc0
        Superblock backups stored on blocks: 
            32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
            4096000

        Allocating group tables: done                            
        Writing inode tables: done                            
        Creating journal (32768 blocks): done
        Writing superblocks and filesystem accounting information: done   
        
        root@ubuntu-20:~# lsblk
        NAME                MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
        sda                   8:0    0    20G  0 disk 
        ├─sda1                8:1    0   512M  0 part /boot/efi
        ├─sda2                8:2    0     1K  0 part 
        └─sda5                8:5    0  19,5G  0 part 
        ├─vgubuntu-root   253:0    0  18,5G  0 lvm  /
        └─vgubuntu-swap_1 253:1    0   976M  0 lvm  [SWAP]
        vda                 252:0    0    20G  0 disk 
        └─vda1              252:1    0    20G  0 part 

Устройство /dev/vda инициализировано

#### Монтирование /dev/vda1

        mkdir /mnt/disk_01

### Добавляем в /etc/fstab запись монтрирования блочного устройства /dev/vda1

        # <file system> <mount point>   <type>  <options>       <dump>  <pass>
        /dev/mapper/vgubuntu-root /               ext4           errors=remount-ro     0       1
        UUID=4FD4-BF1A  /boot/efi                 vfat           umask=0077            0       1
        /dev/mapper/vgubuntu-swap_1 none          swap           sw                    0       0
        /dev/vda1       /mnt/disk_01              ext4            errors=remount-ro    0       1
                                                                                
#### Проверка монтирования,

        mount -a
        
        root@ubuntu-20:~# df -h
        Filesystem                 Size  Used Avail Use% Mounted on
        udev                       1,9G     0  1,9G   0% /dev
        tmpfs                      393M  1,4M  392M   1% /run
        /dev/mapper/vgubuntu-root   19G  6,8G   11G  40% /
        tmpfs                      2,0G   28K  2,0G   1% /dev/shm
        tmpfs                      5,0M  4,0K  5,0M   1% /run/lock
        tmpfs                      2,0G     0  2,0G   0% /sys/fs/cgroup
        /dev/loop0                 128K  128K     0 100% /snap/bare/5
        /dev/loop1                  62M   62M     0 100% /snap/core20/1376
        /dev/loop5                  66M   66M     0 100% /snap/gtk-common-themes/1519
        /dev/loop3                  62M   62M     0 100% /snap/core20/1328
        /dev/loop2                  55M   55M     0 100% /snap/snap-store/558
        /dev/loop4                 249M  249M     0 100% /snap/gnome-3-38-2004/99
        /dev/loop6                  44M   44M     0 100% /snap/snapd/15177
        /dev/loop7                  44M   44M     0 100% /snap/snapd/14978
        /dev/sda1                  511M  4,0K  511M   1% /boot/efi
        tmpfs                      393M   28K  393M   1% /run/user/1000
        /dev/vda1                   20G   45M   19G   1% /mnt/disk_01
        root@ubuntu-20:~# 

Раздел блочного устройства /dev/vda1 примонтирован к ОС.

#### Создание нового каталога для данных кластера Postgresql-14

##### Создание каталога /mnt/disk_01/postgres/data
        
        root@ubuntu-20:~# mkdir -p /mnt/disk_01/postgres/data
        
#### Назначение владельцем каталога /mnt/disk_01/postgres пользователя postgres

        root@ubuntu-20:~# chown -R postgres:postgres /mnt/disk_01/postgres
        
#### Проверка 

        root@ubuntu-20:~# ls -al /mnt/disk_01
        total 28
        drwxr-xr-x 4 root     root      4096 мар 21 17:52 .
        drwxr-xr-x 3 root     root      4096 мар 21 17:43 ..
        drwx------ 2 root     root     16384 мар 21 17:40 lost+found
        drwxr-xr-x 3 postgres postgres  4096 мар 21 17:52 postgres
        root@ubuntu-20:~# 


### Перенос данных кластера Postgres-14 в созданный каталог.

#### Оставка кластера Postgresql-14

      root@ubuntu-20:~# pg_ctlcluster 14 main stop
      
     root@ubuntu-20:~# sudo -u postgres pg_lsclusters 
        Ver Cluster Port Status Owner    Data directory              Log file
        14  main    5432 down   postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log   
   
#### Перенос данных из /var/lib/postgresql/14/main/ в /mnt/disk_01/postgres/data/
        postgres@ubuntu-20:~$ cd /var/lib/postgresql/14/main/
        postgres@ubuntu-20:~/14/main$ ls -al
        total 88
        drwx------ 19 postgres postgres 4096 мар 21 17:59 .
        drwxr-xr-x  3 postgres postgres 4096 мар 21 17:15 ..
        drwx------  6 postgres postgres 4096 мар 21 17:25 base
        drwx------  2 postgres postgres 4096 мар 21 17:59 global
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_commit_ts
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_dynshmem
        drwx------  4 postgres postgres 4096 мар 21 17:59 pg_logical
        drwx------  4 postgres postgres 4096 мар 21 17:15 pg_multixact
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_notify
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_replslot
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_serial
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_snapshots
        drwx------  2 postgres postgres 4096 мар 21 17:59 pg_stat
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_stat_tmp
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_subtrans
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_tblspc
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_twophase
        -rw-------  1 postgres postgres    3 мар 21 17:15 PG_VERSION
        drwx------  3 postgres postgres 4096 мар 21 17:15 pg_wal
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_xact
        -rw-------  1 postgres postgres   88 мар 21 17:15 postgresql.auto.conf
        -rw-------  1 postgres postgres  130 мар 21 17:59 postmaster.opts
        postgres@ubuntu-20:~/14/main$ mv * /mnt/disk_01/postgres/data/
        postgres@ubuntu-20:~/14/main$ ls -al
        total 8
        drwx------ 2 postgres postgres 4096 мар 21 18:02 .
        drwxr-xr-x 3 postgres postgres 4096 мар 21 17:15 ..
        postgres@ubuntu-20:~/14/main$ 

        postgres@ubuntu-20:~/14/main$ ls -al /mnt/disk_01/postgres/data/
        total 88
        drwxr-xr-x 19 postgres postgres 4096 мар 21 18:02 .
        drwxr-xr-x  3 postgres postgres 4096 мар 21 17:52 ..
        drwx------  6 postgres postgres 4096 мар 21 17:25 base
        drwx------  2 postgres postgres 4096 мар 21 17:59 global
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_commit_ts
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_dynshmem
        drwx------  4 postgres postgres 4096 мар 21 17:59 pg_logical
        drwx------  4 postgres postgres 4096 мар 21 17:15 pg_multixact
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_notify
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_replslot
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_serial
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_snapshots
        drwx------  2 postgres postgres 4096 мар 21 17:59 pg_stat
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_stat_tmp
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_subtrans
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_tblspc
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_twophase
        -rw-------  1 postgres postgres    3 мар 21 17:15 PG_VERSION
        drwx------  3 postgres postgres 4096 мар 21 17:15 pg_wal
        drwx------  2 postgres postgres 4096 мар 21 17:15 pg_xact
        -rw-------  1 postgres postgres   88 мар 21 17:15 postgresql.auto.conf
        -rw-------  1 postgres postgres  130 мар 21 17:59 postmaster.opts

Данные перенесены.

### Запуск кластера postgresql-14

        root@ubuntu-20:~# pg_ctlcluster 14 main start
        
#### При запуске выводится сообщение об и предлангается посмотреть в journalctl -xe
        
        Job for postgresql@14-main.service failed because the service did not take the steps required by its unit configuration.
        See "systemctl status postgresql@14-main.service" and "journalctl -xe" for details.
   
   
        root@ubuntu-20:~# journalctl -xe
        -- A stop job for unit postgresql@14-main.service has finished.
        -- 
        -- The job identifier is 3183 and the job result is done.
        мар 21 18:00:33 ubuntu-20.04-01 sudo[6752]:     root : TTY=pts/0 ; PWD=/root ; USER=postgres ; COMMAND=>
        мар 21 18:00:33 ubuntu-20.04-01 sudo[6752]: pam_unix(sudo:session): session opened for user postgres by>
        мар 21 18:00:33 ubuntu-20.04-01 sudo[6752]: pam_unix(sudo:session): session closed for user postgres
        мар 21 18:01:35 ubuntu-20.04-01 su[6756]: (to postgres) asarafanov on pts/0
        мар 21 18:01:35 ubuntu-20.04-01 su[6756]: pam_unix(su-l:session): session opened for user postgres by (>
        мар 21 18:05:01 ubuntu-20.04-01 CRON[6794]: pam_unix(cron:session): session opened for user root by (ui>
        мар 21 18:05:01 ubuntu-20.04-01 CRON[6795]: (root) CMD (command -v debian-sa1 > /dev/null && debian-sa1>
        мар 21 18:05:01 ubuntu-20.04-01 CRON[6794]: pam_unix(cron:session): session closed for user root
        мар 21 18:05:39 ubuntu-20.04-01 su[6756]: pam_unix(su-l:session): session closed for user postgres
        мар 21 18:05:47 ubuntu-20.04-01 systemd[1]: Starting PostgreSQL Cluster 14-main...
        -- Subject: A start job for unit postgresql@14-main.service has begun execution
        -- Defined-By: systemd
        -- Support: http://www.ubuntu.com/support
        -- 
        -- A start job for unit postgresql@14-main.service has begun execution.
        -- 
        -- The job identifier is 3184.
        мар 21 18:05:47 ubuntu-20.04-01 postgresql@14-main[6802]: Error: /usr/lib/postgresql/14/bin/pg_ctl /usr>
        мар 21 18:05:47 ubuntu-20.04-01 postgresql@14-main[6802]: pg_ctl: directory "/var/lib/postgresql/14/mai>
        мар 21 18:05:47 ubuntu-20.04-01 systemd[1]: postgresql@14-main.service: Can't open PID file /run/postgr>
        мар 21 18:05:47 ubuntu-20.04-01 systemd[1]: postgresql@14-main.service: Failed with result 'protocol'.
        -- Subject: Unit failed
        -- Defined-By: systemd
        -- Support: http://www.ubuntu.com/support
        -- 
        -- The unit postgresql@14-main.service has entered the 'failed' state with result 'protocol'.
        мар 21 18:05:47 ubuntu-20.04-01 systemd[1]: Failed to start PostgreSQL Cluster 14-main.
        -- Subject: A start job for unit postgresql@14-main.service has failed
        -- Defined-By: systemd
        -- Support: http://www.ubuntu.com/support
        -- 
        -- A start job for unit postgresql@14-main.service has finished with a failure.
        -- 
        -- The job identifier is 3184 and the job result is failed.

При запуске, service не может найти каталог с данными.

#### Вносим изменения в файл postgresql.conf - /etc/postgresql/14/main/postgresql.conf
    
Изменяем параметр data_directory на '/mnt/disk_01/postgres/data'


#### Запускаем кластер postgresql-14 и получаем ошибку "Не правильные права у каталога /mnt/disk_01/postgres/data".

        root@ubuntu-20:~# pg_ctlcluster 14 main start
        Job for postgresql@14-main.service failed because the service did not take the steps required by its unit configuration.
        See "systemctl status postgresql@14-main.service" and "journalctl -xe" for details.
        root@ubuntu-20:~# systemctl status postgresql@14-main.service
        ● postgresql@14-main.service - PostgreSQL Cluster 14-main
            Loaded: loaded (/lib/systemd/system/postgresql@.service; enabled-runtime; vendor preset: enabled)
            Active: failed (Result: protocol) since Mon 2022-03-21 18:21:00 MSK; 12s ago
            Process: 8621 ExecStart=/usr/bin/pg_ctlcluster --skip-systemctl-redirect 14-main start (code=exited, status=1/FAILURE)

        мар 21 18:21:00 ubuntu-20.04-01 systemd[1]: Starting PostgreSQL Cluster 14-main...
        мар 21 18:21:00 ubuntu-20.04-01 postgresql@14-main[8621]: Error: /usr/lib/postgresql/14/bin/pg_ctl /usr/lib/postgresql/14/bin/pg_ctl start -D /mnt/disk_01/postgres/data -l /var/log/postgresql/postgresql-14-main.log -s -o  -c config_fi>
        мар 21 18:21:00 ubuntu-20.04-01 postgresql@14-main[8621]: 2022-03-21 18:21:00.664 MSK [8626] FATAL:  data directory "/mnt/disk_01/postgres/data" has invalid permissions
        мар 21 18:21:00 ubuntu-20.04-01 postgresql@14-main[8621]: 2022-03-21 18:21:00.664 MSK [8626] DETAIL:  Permissions should be u=rwx (0700) or u=rwx,g=rx (0750).
        мар 21 18:21:00 ubuntu-20.04-01 postgresql@14-main[8621]: pg_ctl: could not start server
        мар 21 18:21:00 ubuntu-20.04-01 postgresql@14-main[8621]: Examine the log output.
        мар 21 18:21:00 ubuntu-20.04-01 systemd[1]: postgresql@14-main.service: Can't open PID file /run/postgresql/14-main.pid (yet?) after start: Operation not permitted
        мар 21 18:21:00 ubuntu-20.04-01 systemd[1]: postgresql@14-main.service: Failed with result 'protocol'.
        мар 21 18:21:00 ubuntu-20.04-01 systemd[1]: Failed to start PostgreSQL Cluster 14-main.

        
        
#### Предоставляем права 700 на каталог /mnt/disk_01/postgres/data        
        
        root@ubuntu-20:~# cd /mnt/disk_01/postgres/
        root@ubuntu-20:/mnt/disk_01/postgres# ls -al
        total 12
        drwxr-xr-x  3 postgres postgres 4096 мар 21 17:52 .
        drwxr-xr-x  4 root     root     4096 мар 21 17:52 ..
        drwxr-xr-x 19 postgres postgres 4096 мар 21 18:12 data
        root@ubuntu-20:/mnt/disk_01/postgres# chmod -R 700 data

#### Запускаем кластер postgresql-14 и проверяем
        
        root@ubuntu-20:/mnt/disk_01/postgres# pg_ctlcluster 14 main start
        
        root@ubuntu-20:/mnt/disk_01/postgres# pg_lsclusters 
        Ver Cluster Port Status Owner    Data directory             Log file
        14  main    5432 online postgres /mnt/disk_01/postgres/data /var/log/postgresql/postgresql-14-main.log

   
 #### Проверяем что с таблицей test БД test
 
        postgres@ubuntu-20:~$ psql
        psql (14.2 (Ubuntu 14.2-1.pgdg20.04+1))
        Type "help" for help.

        postgres=# \l
                                        List of databases
        Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
        -----------+----------+----------+-------------+-------------+-----------------------
        postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
        template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                  |          |          |             |             | postgres=CTc/postgres
        template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
                  |          |          |             |             | postgres=CTc/postgres
        test      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
        (4 rows)

        postgres=# \c test
        You are now connected to database "test" as user "postgres".
        test=# select * from test;
        id |    name1     
        ----+--------------
        1 | Pupkin Vasia
        2 | Ivanov Ivan
        3 | Petrov Petr
        (3 rows)

        test=# 

Данные на месте.
