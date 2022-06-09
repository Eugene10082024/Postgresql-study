### Транзакции

Вывод длинных транзакций

      SELECT
      client_addr, usename, datname,
      clock_timestamp() - xact_start AS xact_age,
      clock_timestamp() - query_start AS query_age,
      state, query
      FROM pg_stat_activity 
      ORDER BY coalesce(xact_start, query_start);
