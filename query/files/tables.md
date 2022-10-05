### Запросы для работы с таблицами

#### Вывод таблиц с наибольшим количеством мертвых строк (tuples)

      select relname, n_live_tup, n_dead_tup from pg_stat_all_tables order by 3 desc;
