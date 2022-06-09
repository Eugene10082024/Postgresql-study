### Запросы для работы в кластере Postgresql

Вывод колисества соединений в кластере Postgresql
      SELECT count(*) AS total_conns FROM pg_stat_activity;
      
Вывод количества соединений от определенного клиента
      SELECT count(*) FROM pg_stat_activity WHERE client_addr = '10.0.20.26';

Вывод длинных транзакций
      SELECT
      client_addr, usename, datname,
      clock_timestamp() - xact_start AS xact_age,
      clock_timestamp() - query_start AS query_age,
      state, query
      FROM pg_stat_activity 
      ORDER BY coalesce(xact_start, query_start);

Вывод статистики по выполняемым соединениям:
      SELECT client_addr, usename, datname, state, count(*) FROM pg_stat_activity GROUP BY 1, 2, 3, 4 ORDER BY 5 DESC;

Определение блокировки одного запроса других:
      SELECT 
      client_addr, usename, datname,
      now() - xact_start AS xact_age,
      now() - query_start AS query_age,
      state, waiting, query
      FROM pg_stat_activity
      WHERE waiting
      ORDER BY coalesce(xact_start, query_start);
      
[Работа с представлением pg_stat_activity](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/query/files/pg_stat_activity.md)
