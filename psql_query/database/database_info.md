### Получение первичной информации по базе данных

Выполните следующие шаги, чтобы немного узнать о базе данных:

1. Используйте этот запрос, чтобы получить список 20 самых больших таблиц в текущей базе данных:
    SELECT oid::REGCLASS::TEXT AS table_name, pg_size_pretty(pg_total_relation_size(oid)) AS total_size FROM pg_class WHERE relkind = 'r' AND relpages > 0 ORDER BY pg_total_relation_size(oid) DESC LIMIT 20;

2. Используйте этот запрос, чтобы получить список 20 самых больших индексов в текущей базе данных и их родительских таблицах:

SELECT indexrelid::REGCLASS::TEXT AS index_name, indrelid::REGCLASS::TEXT AS table_name, pg_size_pretty(pg_relation_size(indexrelid)) AS total_size FROM pg_index ORDER BY pg_relation_size(indexrelid) DESC LIMIT 20;

3. Используйте этот запрос, чтобы найти 20 самых активных таблиц, определив те из них, которые получают больше всего inserts, updates, or deletes:

SELECT relid::REGCLASS AS table_name, 
                n_tup_ins AS inserts, 
                n_tup_upd + n_tup_hot_upd AS updates, 
                n_tup_del AS deletes 
          FROM pg_stat_user_tables 
         ORDER BY (n_tup_ins + n_tup_upd + 
                n_tup_hot_upd + n_tup_del) DESC 
         LIMIT 20;

4. Используйте этот вариант, чтобы получить лучшие таблицы с активностью выборки, проверив сканирование индекса и таблицы:
(Use this variant to obtain top tables with fetch activity by checking index and table scans:)

SELECT relid::REGCLASS AS table_name, 
               coalesce(seq_scan, 0) AS sequential_scans, 
               coalesce(idx_scan, 0) AS index_scans, 
               coalesce(seq_tup_read, 0) AS table_matches, 
               coalesce(idx_tup_fetch, 0) AS index_matches 
          FROM pg_stat_user_tables 
         ORDER BY (coalesce(seq_scan, 0) +  
               coalesce(idx_scan, 0)) DESC, 
               (coalesce(seq_tup_read, 0) + 
               coalesce(idx_tup_fetch, 0)) DESC 
         LIMIT 20;

5. Используйте этот запрос для первых 20 индексов с активностью чтения в текущей базе данных:
(Use this query for the top 20 indexes with read activity in the current database:)

SELECT indexrelid::REGCLASS AS index_name, 
               coalesce(idx_scan, 0) AS index_scans, 
               coalesce(idx_tup_read, 0) AS rows_read, 
               coalesce(idx_tup_fetch, 0) AS rows_fetched 
          FROM pg_stat_user_indexes 
         ORDER BY (coalesce(idx_scan, 0) +  
                coalesce(idx_tup_read, 0)) DESC 
         LIMIT 20;
