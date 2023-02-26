### Работа с автовакуумом

#### Запрос определющий когда autovacuum обработал Ваши таблицы крайний раз:

            SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum FROM pg_stat_all_tables ORDER BY n_dead_tup
            /(n_live_tup * current_setting('autovacuum_vacuum_scale_factor')::float8
            + current_setting('autovacuum_vacuum_threshold')::float8)
            DESC
            LIMIT 10;

Автовакуум недавно запустился, но мертвые кортежи не освободил. Мы можем проверить проблему, запустив VACUUM (VERBOSE):

            VACUUM VERBOSE name-table;

##### Проблемы не удаления dead_tuples autovacuum и пути их решения

1. Long-running transactions :

            SELECT pid, datname, usename, state, backend_xmin, backend_xid FROM pg_stat_activity WHERE backend_xmin IS NOT NULL OR backend_xid IS NOT NULL ORDER BY greatest(age(backend_xmin), age(backend_xid)) DESC;

Удаление: select pg_terminate_backend(pid)

2. Заброшенные слоты репликации:

            SELECT slot_name, slot_type, database, xmin FROM pg_replication_slots ORDER BY age(xmin) DESC;

Удаление: pg_drop_replication_slot() 

3. Осиротевшие repared transactions:

            SELECT gid, prepared, owner, database, transaction AS xmin FROM pg_prepared_xacts ORDER BY age(transaction) DESC;

Используйте ROLLBACK PREPARED SQL запрос для удаления prepared transactions.

4. Standby server with hot_standby_feedback = on:

Чтобы узнать xmin всех резервных серверов, вы можете запустить следующий запрос на основном сервере:

            SELECT application_name, client_addr, backend_xmin FROM pg_stat_replication ORDER BY age(backend_xmin) DESC;

#### VACUUM activity:

            SELECT
                    p.pid,
                    now() - a.xact_start AS duration,
                    coalesce(wait_event_type ||'.'|| wait_event, 'f') AS waiting,
                    CASE 
                            WHEN a.query ~ '^autovacuum.*to prevent wraparound' THEN 'wraparound' 
                            WHEN a.query ~ '^vacuum' THEN 'user'
                            ELSE 'regular'
                    END AS mode,
                    p.datname AS database,
                    p.relid::regclass AS table,
                    p.phase,
                    pg_size_pretty(p.heap_blks_total * current_setting('block_size')::int) AS table_size,
                    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
                    pg_size_pretty(p.heap_blks_scanned * current_setting('block_size')::int) AS scanned,
                    pg_size_pretty(p.heap_blks_vacuumed * current_setting('block_size')::int) AS vacuumed,
                    round(100.0 * p.heap_blks_scanned / p.heap_blks_total, 1) AS scanned_pct,
                    round(100.0 * p.heap_blks_vacuumed / p.heap_blks_total, 1) AS vacuumed_pct,
                    p.index_vacuum_count,
                    round(100.0 * p.num_dead_tuples / p.max_dead_tuples,1) AS dead_pct
            FROM pg_stat_progress_vacuum p
            RIGHT JOIN pg_stat_activity a ON a.pid = p.pid
            WHERE (a.query ~* '^autovacuum:' OR a.query ~* '^vacuum') AND a.pid <> pg_backend_pid()
            ORDER BY now() - a.xact_start DESC;
