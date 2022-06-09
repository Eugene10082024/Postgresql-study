### Запросы для работы в кластере Postgresql

[Работа с соединениями](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/query/file/connection.md)

Вывод длинных транзакций

      SELECT
      client_addr, usename, datname,
      clock_timestamp() - xact_start AS xact_age,
      clock_timestamp() - query_start AS query_age,
      state, query
      FROM pg_stat_activity 
      ORDER BY coalesce(xact_start, query_start);



Вывод блокировки одного запроса других:

      SELECT 
      client_addr, usename, datname,
      now() - xact_start AS xact_age,
      now() - query_start AS query_age,
      state, waiting, query
      FROM pg_stat_activity
      WHERE waiting
      ORDER BY coalesce(xact_start, query_start);
      
#### Дополнительная информация
      
[Работа с представлением pg_stat_activity](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/query/files/pg_stat_activity.md)
