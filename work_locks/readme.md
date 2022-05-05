### Механизм блокировок

Цель:

понимать как работает механизм блокировок объектов и строк

### Выполнение ДЗ

#### 1. Настройте сервер так, чтобы в журнал сообщений сбрасывалась информация о блокировках, удерживаемых более 200 миллисекунд. Воспроизведите ситуацию, при которой в журнале появятся такие сообщения.

Для выполнения данного требоsuвания необходимо настроить следующие параметры в postgresql.conf:

deadlock_timeout - ремя ожидания блокировки (в миллисекундах), по истечении которого будет выполняться проверка состояния взаимоблокировки. Эта проверка довольно дорогостоящая, поэтому сервер не выполняет её при всяком ожидании блокировки. 

Когда включён параметр log_lock_waits, данный параметр также определяет, спустя какое время в журнал сервера будут записываться сообщения об ожидании блокировки.

        deadlock_timeout = 200 ms
        log_lock_waits = on

##### Создаем БД для нагрузочного тестирования pgbench
        postgres@ubuntu-20:~$ psql
        psql (14.2 (Ubuntu 14.2-1.pgdg20.04+1+b1))
        Type "help" for help.

        postgres=# drop database benchmark ;
        DROP DATABASE
        postgres=# create database benchmark;
        CREATE DATABASE
        postgres=# \q
        postgres@ubuntu-20:~$ pgbench -i benchmark -s 100
        dropping old tables...
        NOTICE:  table "pgbench_accounts" does not exist, skipping
        NOTICE:  table "pgbench_branches" does not exist, skipping
        NOTICE:  table "pgbench_history" does not exist, skipping
        NOTICE:  table "pgbench_tellers" does not exist, skipping
        creating tables...
        generating data (client-side)...
        10000000 of 10000000 tuples (100%) done (elapsed 80.14 s, remaining 0.00 s)
        vacuuming...
        creating primary keys...
        done in 126.81 s (drop tables 0.00 s, create tables 0.67 s, client-side generate 81.31 s, vacuum 23.71 s, primary keys 21.12 s).

##### Запускаем нагрузочный тест pgbench и выполняем анализ log файла

      postgres@ubuntu-20:~$ pgbench -U postgres -c 10  -j 4 -P 60 -T 600 benchmark

Смотрил log файл postgresql: tail -f /var/log/postgresql/postgresql-14-main.log 

В процессе выполнения нагрузочного теста появляется информация о ShareLock при выполнении UPDATE

        2022-04-11 08:54:38.226 MSK [18717] postgres@benchmark LOG:  process 18717 still waiting for ShareLock on transaction 50690 after 200.082 ms
        2022-04-11 08:54:38.226 MSK [18717] postgres@benchmark DETAIL:  Process holding the lock: 18709. Wait queue: 18717.
        2022-04-11 08:54:38.226 MSK [18717] postgres@benchmark CONTEXT:  while updating tuple (0,137) in relation "pgbench_branches"
        2022-04-11 08:54:38.226 MSK [18717] postgres@benchmark STATEMENT:  UPDATE pgbench_branches SET bbalance = bbalance + 535 WHERE bid = 28;
        2022-04-11 08:54:38.241 MSK [18717] postgres@benchmark LOG:  process 18717 acquired ShareLock on transaction 50690 after 214.598 ms
        2022-04-11 08:54:38.241 MSK [18717] postgres@benchmark CONTEXT:  while updating tuple (0,137) in relation "pgbench_branches"
        2022-04-11 08:54:38.241 MSK [18717] postgres@benchmark STATEMENT:  UPDATE pgbench_branches SET bbalance = bbalance + 535 WHERE bid = 28;
        2022-04-11 08:54:52.895 MSK [18708] postgres@benchmark LOG:  process 18708 still waiting for ShareLock on transaction 53797 after 200.053 ms
        2022-04-11 08:54:52.895 MSK [18708] postgres@benchmark DETAIL:  Process holding the lock: 18717. Wait queue: 18708.
        2022-04-11 08:54:52.895 MSK [18708] postgres@benchmark CONTEXT:  while updating tuple (0,231) in relation "pgbench_branches"
        2022-04-11 08:54:52.895 MSK [18708] postgres@benchmark STATEMENT:  UPDATE pgbench_branches SET bbalance = bbalance + -2296 WHERE bid = 52;
        2022-04-11 08:54:52.896 MSK [18708] postgres@benchmark LOG:  process 18708 acquired ShareLock on transaction 53797 after 201.016 ms
        2022-04-11 08:54:52.896 MSK [18708] postgres@benchmark CONTEXT:  while updating tuple (0,231) in relation "pgbench_branches"
        2022-04-11 08:54:52.896 MSK [18708] postgres@benchmark STATEMENT:  UPDATE pgbench_branches SET bbalance = bbalance + -2296 WHERE bid = 52;
        2022-04-11 08:55:15.735 MSK [18745] LOG:  automatic vacuum of table "benchmark.public.pgbench_branches": index scans: 0
        
##### Запустим UPDATE в таблице  pgbench_accounts поля pgbench_accounts в двух сессиях:
 
В первой сессии:
 
            benchmark=# UPDATE pgbench_accounts SET abalance=6000 where (bid=92 or bid=91 or bid=93 or bid=100);
            
Во второй сессии:
    
            benchmark=# UPDATE pgbench_accounts SET abalance=4000 where (bid=92 or bid=91 or bid=93);
        
В /var/log/postgresql/postgresql-14-main.log получаем следующие сообщения об ожидании блокировок.

        2022-04-11 09:23:10.218 MSK [2551] LOG:  checkpoint starting: time
        2022-04-11 09:23:37.116 MSK [18976] postgres@benchmark LOG:  process 18976 still waiting for ShareLock on transaction 123865 after 200.069 ms
        2022-04-11 09:23:37.116 MSK [18976] postgres@benchmark DETAIL:  Process holding the lock: 18821. Wait queue: 18976.
        2022-04-11 09:23:37.116 MSK [18976] postgres@benchmark CONTEXT:  while updating tuple (179024,1) in relation "pgbench_accounts"
        2022-04-11 09:23:37.116 MSK [18976] postgres@benchmark STATEMENT:  UPDATE pgbench_accounts SET abalance=4000 where (bid=92 or bid=91 or bid=93);
        2022-04-11 09:23:39.780 MSK [18976] postgres@benchmark LOG:  process 18976 acquired ShareLock on transaction 123865 after 2864.078 ms
        2022-04-11 09:23:39.780 MSK [18976] postgres@benchmark CONTEXT:  while updating tuple (179024,1) in relation "pgbench_accounts"
        2022-04-11 09:23:39.780 MSK [18976] postgres@benchmark STATEMENT:  UPDATE pgbench_accounts SET abalance=4000 where (bid=92 or bid=91 or bid=93);
        
#### 2. Смоделируйте ситуацию обновления одной и той же строки тремя командами UPDATE в разных сеансах. Изучите возникшие блокировки в представлении pg_locks и убедитесь, что все они понятны. Пришлите список блокировок и объясните, что значит каждая.

        postgres@ubuntu-20:~$ psql
        psql (14.2 (Ubuntu 14.2-1.pgdg20.04+1+b1))
        Type "help" for help.

        postgres=# \c database_locks 
        You are now connected to database "database_locks" as user "postgres".
        
        database_locks=# select * from test_lock_update;
        
       id |     name      |    role     |       email        
       ---+---------------+-------------+--------------------
        2 | Sidorov Sidor | admin of 1C | sidorov@yandex.ru
        3 | Petron Petr   | admin linux | petrov@rambler.ru
        4 | Pypkin Vasia  | Super Admin | vpupkin@rambler.ru
        1 | Ivanov Ivan   | user of 1C  | ivanov@yandex.ru
        (4 rows)

Будем в трех сессиях редактировать (UPDATE) запись с id=3 и посмотрим что получится.

##### Первая сессия:
        database_locks=# BEGIN;
        BEGIN
        database_locks=*# select pg_backend_pid();
        pg_backend_pid 
        ----------------
                2489
        (1 row)

        database_locks=*# UPDATE test_lock_update SET role='Admin Windows' where id=3;
        UPDATE 1
        database_locks=*# SELECT locktype, relation::REGCLASS,virtualxid AS virtxid,transactionid AS xid,mode,granted FROM pg_locks WHERE pid=2489;
        
          locktype    |     relation     | virtxid |  xid   |       mode       | granted 
        --------------+------------------+---------+--------+------------------+---------
        relation      | pg_locks         |         |        | AccessShareLock  | t
        relation      | test_lock_update |         |        | RowExclusiveLock | t
        virtualxid    |                  | 4/55    |        | ExclusiveLock    | t
        transactionid |                  |         | 123889 | ExclusiveLock    | t
        (4 rows)

Из представления видно, что оператор UPDATE в таблице test_lock_update получил эксклюзивную блокировку на строку (RowExclusiveLock).
Также UPDATE получил ExclusiveLock блокировку.

EclusiveLock удерживается транзакцией 123889 первой сессий. 

##### Вторая сессия:
        database_locks=# begin;
        BEGIN
        database_locks=*# select pg_backend_pid();
        pg_backend_pid 
        ----------------
                2505
        (1 row)

        database_locks=*# UPDATE test_lock_update SET role='Admin Ubuntu' where id=3;

Далее сессия зависла, ждет выполнение первой сессии.

        database_locks=# SELECT locktype, relation::REGCLASS,virtualxid AS virtxid,transactionid AS xid,mode,granted FROM pg_locks WHERE pid=2505;
        
          locktype    |     relation     | virtxid |  xid   |       mode       | granted 
       ---------------+------------------+---------+--------+------------------+---------
        relation      | test_lock_update |         |        | RowExclusiveLock | t
        virtualxid    |                  | 5/5     |        | ExclusiveLock    | t
        tuple         | test_lock_update |         |        | ExclusiveLock    | t
        transactionid |                  |         | 123889 | ShareLock        | f
        transactionid |                  |         | 123890 | ExclusiveLock    | t
        (5 rows)

Из представления состояния второй сессии видно, что вторая транзакция ожидаем выполнения commit/rollback прежде чем проболжить выполние   ShareLock (granted = f) 

При этом транзакция второй сессии устанавливает ExclusiveLock на собственный идентификатор транзакции при запуске..

Появился tuple  который показывает что процесс ожибает блокировки строки в таблице test_lock_update.
        
##### Третья сессия
        
        database_locks=*# UPDATE test_lock_update SET role='Admin Astra Linux' where id=3;        

        database_locks=# begin;
        BEGIN
        database_locks=*# select pg_backend_pid();
        pg_backend_pid 
        ----------------
                2508
        (1 row)

        database_locks=*# UPDATE test_lock_update SET role='Admin Astra Linux' where id=3;

Далее сессия зависла, ждет выполнение первой и второй сессий.

        database_locks=# SELECT locktype, relation::REGCLASS,virtualxid AS virtxid,transactionid AS xid,mode,granted FROM pg_locks WHERE pid=2508;
          locktype    |     relation     | virtxid |  xid   |       mode       | granted 
       ---------------+------------------+---------+--------+------------------+---------
        relation      | test_lock_update |         |        | RowExclusiveLock | t
        virtualxid    |                  | 6/4     |        | ExclusiveLock    | t
        tuple         | test_lock_update |         |        | ExclusiveLock    | f
        transactionid |                  |         | 123891 | ExclusiveLock    | t
        (4 rows)
        
##### Выполнен COMMIT в первой сессии

        database_locks=# SELECT locktype, relation::REGCLASS,virtualxid AS virtxid,transactionid AS xid,mode,granted FROM pg_locks WHERE pid=2505;
        
          locktype    |     relation     | virtxid |  xid   |       mode       | granted 
       ---------------+------------------+---------+--------+------------------+---------
        relation      | test_lock_update |         |        | RowExclusiveLock | t
        virtualxid    |                  | 5/5     |        | ExclusiveLock    | t
        transactionid |                  |         | 123890 | ExclusiveLock    | t
        (3 rows)

        database_locks=# SELECT locktype, relation::REGCLASS,virtualxid AS virtxid,transactionid AS xid,mode,granted FROM pg_locks WHERE pid=2508;
        
          locktype    |     relation     | virtxid |  xid   |       mode       | granted 
       ---------------+------------------+---------+--------+------------------+---------
        relation      | test_lock_update |         |        | RowExclusiveLock | t
        virtualxid    |                  | 6/4     |        | ExclusiveLock    | t
        transactionid |                  |         | 123890 | ShareLock        | f
        transactionid |                  |         | 123891 | ExclusiveLock    | t
        (4 rows)

##### Выполнен COMMIT во второй сессии

        database_locks=# SELECT locktype, relation::REGCLASS,virtualxid AS virtxid,transactionid AS xid,mode,granted FROM pg_locks WHERE pid=2508;
        
          locktype    |     relation     | virtxid |  xid   |       mode       | granted 
       ---------------+------------------+---------+--------+------------------+---------
        relation      | test_lock_update |         |        | RowExclusiveLock | t
        virtualxid    |                  | 6/4     |        | ExclusiveLock    | t
        transactionid |                  |         | 123891 | ExclusiveLock    | t
        (3 rows)

##### 3. Воспроизведите взаимоблокировку трех транзакций. Можно ли разобраться в ситуации постфактум, изучая журнал сообщений?

Присваиваем значение on параметру log_lock_waits
    postgres=# show deadlock_timeout ;
        deadlock_timeout 
        ------------------
        1s
        (1 row)

        postgres=# show log_lock_waits ;
        log_lock_waits 
        ----------------
        on
        (1 row)


##### Последовательность действий.

Первая сессия

    database_locks=# begin;
    BEGIN
    database_locks=*# update test_lock_update set email='i.ivanov@yandex.ru' where id=1;
    UPDATE 1
   
Вторая сессия:

    database_locks=# begin;
    BEGIN
    database_locks=*# update test_lock_update set email='i.ivanov@yandex.ru' where id=1;
    UPDATE 1

Третья сессия:

    database_locks=# begin;
    BEGIN
    database_locks=*# update test_lock_update set email='p.petrov@yandex.ru' where id=3;
    UPDATE 1

Первая сессия    
    
    database_locks=*# update test_lock_update set email='p.petrov@rambler.ru' where id=3;
    сессия подвисает
    
Вторая сессия 
    
    database_locks=*# update test_lock_update set email='p.petrov@rambler.ru' where id=3;
    сессия подвисает
    
Третья сессия:

    database_locks=*# update test_lock_update set email='ivanov@yandex.ru' where id=1;
    ERROR:  deadlock detected
    DETAIL:  Process 4459 waits for ShareLock on transaction 123899; blocked by process 4472.
    Process 4472 waits for ShareLock on transaction 123900; blocked by process 4459.
    HINT:  See server log for query details.
    CONTEXT:  while updating tuple (0,9) in relation "test_lock_update"

##### Смотрим log postgresql на предмет daedlock:
    
less /var/log/postgresql/postgresql-14-main.log
        
        2022-04-17 19:52:45.313 MSK [4427] LOG:  database system is ready to accept connections
        2022-04-17 19:57:45.405 MSK [4429] LOG:  checkpoint starting: time
        2022-04-17 19:57:45.606 MSK [4429] LOG:  checkpoint complete: wrote 3 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.036 s, sync=0.029 s, total=0.201 s; sync files=2, longest=0.022 s, average=0.015 s; distance=0 kB, estimate=0 kB
        2022-04-17 20:00:04.777 MSK [4472] postgres@database_locks LOG:  process 4472 still waiting for ShareLock on transaction 123900 after 1000.073 ms
        2022-04-17 20:00:04.777 MSK [4472] postgres@database_locks DETAIL:  Process holding the lock: 4459. Wait queue: 4472.
        2022-04-17 20:00:04.777 MSK [4472] postgres@database_locks CONTEXT:  while updating tuple (0,15) in relation "test_lock_update"
        2022-04-17 20:00:04.777 MSK [4472] postgres@database_locks STATEMENT:  update test_lock_update set email='p.petrov@rambler.ru' where id=3;
        2022-04-17 20:00:43.862 MSK [4458] postgres@database_locks ERROR:  syntax error at or near "update" at character 68
        2022-04-17 20:00:43.862 MSK [4458] postgres@database_locks STATEMENT:  update test_lock_update set email='s.sidorov@yandex.ru' where id=2
                update test_lock_update set email='p.petrov@gmail.ru' where id=3
                ;
        2022-04-17 20:01:46.613 MSK [4458] postgres@database_locks ERROR:  syntax error at or near "pdate" at character 1
        2022-04-17 20:01:46.613 MSK [4458] postgres@database_locks STATEMENT:  pdate test_lock_update set email='p.petrov@gmail.ru' where id=3;
        2022-04-17 20:01:59.214 MSK [4458] postgres@database_locks ERROR:  current transaction is aborted, commands ignored until end of transaction block
        2022-04-17 20:01:59.214 MSK [4458] postgres@database_locks STATEMENT:  update test_lock_update set email='p.petrov@gmail.ru' where id=3;
        2022-04-17 20:02:45.658 MSK [4429] LOG:  checkpoint starting: time
        2022-04-17 20:02:45.940 MSK [4429] LOG:  checkpoint complete: wrote 2 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.119 s, sync=0.041 s, total=0.282 s; sync files=2, longest=0.024 s, average=0.021 s; distance=2 kB, estimate=2 kB
        2022-04-17 20:03:07.126 MSK [4458] postgres@database_locks LOG:  process 4458 still waiting for ExclusiveLock on tuple (0,15) of relation 16522 of database 16516 after 1000.081 ms
        2022-04-17 20:03:07.126 MSK [4458] postgres@database_locks DETAIL:  Process holding the lock: 4472. Wait queue: 4458.
        2022-04-17 20:03:07.126 MSK [4458] postgres@database_locks STATEMENT:  update test_lock_update set email='p.petrov@gmail.ru' where id=3;
        2022-04-17 20:03:42.322 MSK [4459] postgres@database_locks LOG:  process 4459 detected deadlock while waiting for ShareLock on transaction 123899 after 1000.098 ms
        2022-04-17 20:03:42.322 MSK [4459] postgres@database_locks DETAIL:  Process holding the lock: 4472. Wait queue: .
        2022-04-17 20:03:42.322 MSK [4459] postgres@database_locks CONTEXT:  while updating tuple (0,9) in relation "test_lock_update"
        2022-04-17 20:03:42.322 MSK [4459] postgres@database_locks STATEMENT:  update test_lock_update set email='ivanov@yandex.ru' where id=1;
        2022-04-17 20:03:42.322 MSK [4459] postgres@database_locks ERROR:  deadlock detected
        2022-04-17 20:03:42.322 MSK [4459] postgres@database_locks DETAIL:  Process 4459 waits for ShareLock on transaction 123899; blocked by process 4472.
                Process 4472 waits for ShareLock on transaction 123900; blocked by process 4459.
                Process 4459: update test_lock_update set email='ivanov@yandex.ru' where id=1;
                Process 4472: update test_lock_update set email='p.petrov@rambler.ru' where id=3;
        2022-04-17 20:03:42.322 MSK [4459] postgres@database_locks HINT:  See server log for query details.
        2022-04-17 20:03:42.322 MSK [4459] postgres@database_locks CONTEXT:  while updating tuple (0,9) in relation "test_lock_update"
        2022-04-17 20:03:42.322 MSK [4459] postgres@database_locks STATEMENT:  update test_lock_update set email='ivanov@yandex.ru' where id=1;
        2022-04-17 20:03:42.322 MSK [4472] postgres@database_locks LOG:  process 4472 acquired ShareLock on transaction 123900 after 218545.187 ms
        2022-04-17 20:03:42.322 MSK [4472] postgres@database_locks CONTEXT:  while updating tuple (0,15) in relation "test_lock_update"
        2022-04-17 20:03:42.322 MSK [4472] postgres@database_locks STATEMENT:  update test_lock_update set email='p.petrov@rambler.ru' where id=3;
        2022-04-17 20:03:42.323 MSK [4458] postgres@database_locks LOG:  process 4458 acquired ExclusiveLock on tuple (0,15) of relation 16522 of database 16516 after 36196.921 ms
        2022-04-17 20:03:42.323 MSK [4458] postgres@database_locks STATEMENT:  update test_lock_update set email='p.petrov@gmail.ru' where id=3;
        2022-04-17 20:03:43.323 MSK [4458] postgres@database_locks LOG:  process 4458 still waiting for ShareLock on transaction 123899 after 1000.089 ms
        2022-04-17 20:03:43.323 MSK [4458] postgres@database_locks DETAIL:  Process holding the lock: 4472. Wait queue: 4458.
        2022-04-17 20:03:43.323 MSK [4458] postgres@database_locks CONTEXT:  while updating tuple (0,15) in relation "test_lock_update"
        2022-04-17 20:03:43.323 MSK [4458] postgres@database_locks STATEMENT:  update test_lock_update set email='p.petrov@gmail.ru' where id=3;
        2022-04-17 20:04:33.015 MSK [4459] postgres@database_locks ERROR:  current transaction is aborted, commands ignored until end of transaction block
        2022-04-17 20:04:33.015 MSK [4459] postgres@database_locks STATEMENT:  update test_lock_update set email='sidorov@yandex.ru' where id=2;
        2022-04-17 20:04:53.874 MSK [4458] postgres@database_locks LOG:  process 4458 acquired ShareLock on transaction 123899 after 71551.678 ms
        2022-04-17 20:04:53.874 MSK [4458] postgres@database_locks CONTEXT:  while updating tuple (0,15) in relation "test_lock_update"
        2022-04-17 20:04:53.874 MSK [4458] postgres@database_locks STATEMENT:  update test_lock_update set email='p.petrov@gmail.ru' where id=3;
        2022-04-17 20:07:46.040 MSK [4429] LOG:  checkpoint starting: time
        
Из log файла следует (2022-04-17 20:03:42.322 MSK ), что взаимоблокировка возникла между двумя процессами: процессом 4459 и процессом 4472 при выполнении команды процессом 4459:

update test_lock_update set email='ivanov@yandex.ru' where id=1;
        

#### 4. Могут ли две транзакции, выполняющие единственную команду UPDATE одной и той же таблицы (без where), заблокировать друг друга?  

Выяснение возможности блокировки и взаимоблокировки транзакций буду выполнять на таблице test_lock_update.

Обновлять буду поле email.

                database_locks=# select * from test_lock_update ;
                 id |     name      |       role        |        email        
                ----+---------------+-------------------+---------------------
                  4 | Pypkin Vasia  | Super Admin       | vpupkin@rambler.ru
                  5 | Student-01    | user windows      | sudent01@rambler.ru
                  6 | Student-02    | user windows      | sudent02@rambler.ru
                  7 | Student-03    | user windows      | sudent03@rambler.ru
                  8 | Student-04    | user linux        | sudent04@yandex.ru
                  9 | Student-05    | user linux        | sudent05@yandex.ru
                 10 | Student-06    | user linux        | sudent06@yandex.ru
                  1 | Ivanov Ivan   | user of 1C        | i.ivanov@yandex.ru
                  2 | Sidorov Sidor | admin of 1C       | s.sidorov@yandex.ru
                  3 | Petron Petr   | Admin Astra Linux | p.petrov@gmail.ru
                (10 rows)

##### Первая транзакция
                database_locks=# begin;
                BEGIN
                database_locks=*# select pg_backend_pid();
                pg_backend_pid 
                ----------------
                        2626
                (1 row)

                database_locks=*# update test_lock_update set email='noname@mail.ru';
                UPDATE 10
                database_locks=*# 


##### Вторая транзакция

                database_locks=# begin;
                BEGIN
                database_locks=*# select pg_backend_pid();
                pg_backend_pid 
                ----------------
                        2714
                (1 row)

                database_locks=*# update test_lock_update set email='noname@rambler.ru';

Вторая транзакция зависла в ожидании освобождения блокировки ShareLock.

В Log файле видно что вторая транзакция ожидает блокировки ShareLock. 

        2022-05-05 08:14:52.345 MSK [2714] postgres@database_locks LOG:  process 2714 still waiting for ShareLock on transaction 123908 after 1000.260 ms
        2022-05-05 08:14:52.345 MSK [2714] postgres@database_locks DETAIL:  Process holding the lock: 2626. Wait queue: 2714.
        2022-05-05 08:14:52.345 MSK [2714] postgres@database_locks CONTEXT:  while updating tuple (0,7) in relation "test_lock_update"
        2022-05-05 08:14:52.345 MSK [2714] postgres@database_locks STATEMENT:  update test_lock_update set email='noname@rambler.ru';

Также это видно из представления pg_locks

        database_locks: SELECT locktype, relation::REGCLASS,virtualxid AS virtxid,transactionid AS xid,mode,granted FROM pg_locks WHERE pid=2626;
        locktype    |     relation     | virtxid |  xid   |       mode       | granted 
        ---------------+------------------+---------+--------+------------------+---------
        relation      | pg_locks         |         |        | AccessShareLock  | t
        relation      | test_lock_update |         |        | RowExclusiveLock | t
        virtualxid    |                  | 4/10    |        | ExclusiveLock    | t
        transactionid |                  |         | 123908 | ExclusiveLock    | t
        (4 rows)

        database_locks=*# SELECT locktype, relation::REGCLASS,virtualxid AS virtxid,transactionid AS xid,mode,granted FROM pg_locks WHERE pid=2714;
        locktype    |     relation     | virtxid |  xid   |       mode       | granted 
        ---------------+------------------+---------+--------+------------------+---------
        relation      | test_lock_update |         |        | RowExclusiveLock | t
        virtualxid    |                  | 5/6     |        | ExclusiveLock    | t
        tuple         | test_lock_update |         |        | ExclusiveLock    | t
        transactionid |                  |         | 123908 | ShareLock        | f
        transactionid |                  |         | 123909 | ExclusiveLock    | t
        (5 rows)


Вывод: Первая транзакция с оператором UPDATE будет блокировать выпополнение второй транзакции с оператором UPDATE, которая в свою очередь будет ожидать освобождения блокировки ShareLock первой транзакцией.
При этом если выполнить повторный UPDATE в первой транзакции, то он пройдет так как в данная транзакция имеет все необходимые блокировки.
В данном случае взаимоблокировки не произойдет.





