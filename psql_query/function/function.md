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
