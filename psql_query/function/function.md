### Работа с функциями

      \df - вывод списка доступных функций, которые есть в кластере Postgres
      
Вывод текущего LSN:

      SELECT pg_current_wal_lsn();
      
Принудительное переключение WAL файла:

      SELECT pg_switch_wal();

Вывод postgres из recovery archive_mode

      SELECT pg_wal_replay_resume(); 

Обнуление всей статиски активности:

      SELECT pg_stat_reset();


#### Определение состояние кластера Postgres

Определение номера порта который слушает сервер:

    select inet_server_port();
    
Текущая база данных:

    select current_database();
    
Идентификатор текущего пользователя:

    select current_user;
    
IP адрес сервера, принявшего соединение:

    select inet_server_addr()
    
Текущая версия сервера Postgres:

    select version();

Определение времени работы сервера:

    select date_trunc(‘second’, current_timestamp-pg_postmaster_start_time()) as uptime;
    
Определение времени запуска сервера

    select pg_postmaster_start_time();

