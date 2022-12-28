### Получение информации по Индексам

#### Index Cache Hit Rate (сколько ваших индексов находится в вашем кеше)

    SELECT 
      sum(idx_blks_read) as idx_read,
      sum(idx_blks_hit)  as idx_hit,
      (sum(idx_blks_hit) - sum(idx_blks_read)) / sum(idx_blks_hit) as ratio
    FROM 
      pg_statio_user_indexes;

#### Размер таблиц вместе с индексами:

    SELECT TABLE_NAME,pg_size_pretty(table_size) AS table_size, pg_size_pretty(indexes_size) AS indexes_size, pg_size_pretty(total_size) AS total_size 
    FROM (
        SELECT
            TABLE_NAME,pg_table_size(TABLE_NAME) AS table_size, pg_indexes_size(TABLE_NAME) AS indexes_size,pg_total_relation_size(TABLE_NAME) AS total_size
        FROM (
            SELECT ('"' || table_schema || '"."' || TABLE_NAME || '"') AS TABLE_NAME
            FROM information_schema.tables
        ) AS all_tables
        ORDER BY total_size DESC
        ) AS pretty_sizes;

#### Просмотр как были созданы индексы

    SELECT tablename, indexname, indexdef FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename,indexname;
    
#### Просмотр неиспользуемых индексов:

      SELECT s.schemaname,
             s.relname AS tablename,
             s.indexrelname AS indexname,
             pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_size,
             s.idx_scan
      FROM pg_catalog.pg_stat_user_indexes s
         JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
      WHERE s.idx_scan < 10      -- has never been scanned
        AND 0 <>ALL (i.indkey)  -- no index column is an expression
        AND NOT i.indisunique   -- is not a UNIQUE index
        AND NOT EXISTS          -- does not enforce a constraint
               (SELECT 1 FROM pg_catalog.pg_constraint c
                WHERE c.conindid = s.indexrelid)
      ORDER BY pg_relation_size(s.indexrelid) DESC;
