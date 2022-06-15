### Получение информации по блокировкам запросов

Вывод блокировки одного запроса других:

      SELECT 
      client_addr, usename, datname,
      now() - xact_start AS xact_age,
      now() - query_start AS query_age,
      state, waiting, query
      FROM pg_stat_activity
      WHERE waiting
      ORDER BY coalesce(xact_start, query_start);
