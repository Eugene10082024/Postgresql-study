### Работа с репликацией

    postgres=# select pg_is_in_recovery();
    
Запрос на получение информации о слотах репликации:

    postgres=# select * from pg_replication_slots ;

#### Лаги репликации

Лаги репликации — это когда один и тот же запрос, выполненный на мастере и на реплике, возвращает разные данные. Это значит, что данные неконсистентны между мастером и репликами, и есть какое-то отставание. Реплике нужно воспроизвести часть журналов транзакций, чтобы догнать мастера. Основной симптом выглядит именно так: есть запрос, и они возвращают разные результаты.

pg_stat_replication. Оно показывает информацию по всем WAL Sender, то есть по процессам, которые занимаются отправкой журнала транзакций. Для каждой реплики будет отдельная строчка, которая показывает статистику именно по этой реплике.

        SELECT client_addr AS client, usename AS user, application_name AS name,
        state, sync_state AS mode,
        (pg_wal_lsn_diff(pg_current_wal_lsn(),sent_lsn)/1024)::int as pending,
        (pg_wal_lsn_diff(sent_lsn,write_lsn)/1024)::int as write,
        (pg_wal_lsn_diff(write_lsn,flush_lsn)/1024)::int as flush,
        (pg_wal_lsn_diff(flush_lsn,replay_lsn)/1024)::int replay,
        (pg_wal_lsn_diff(pg_current_wal_lsn(),replay_lsn))::int/1024 as total_lag
        FROM pg_stat_replication;

    client      |    user    |    name     |   state   | mode  | pending | write | flush | replay | total_lag 
-----------------+------------+-------------+-----------+-------+---------+-------+-------+--------+-----------
 192.168.122.171 | replicator | redoc-pgs02 | streaming | async |       0 |     0 |     0 |      0 |         0
(1 строка)
