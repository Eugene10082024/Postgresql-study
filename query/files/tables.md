### Запросы для работы с таблицами

#### Вывод таблиц с наибольшим количеством мертвых строк (tuples)

      select relname, n_live_tup, n_dead_tup from pg_stat_all_tables order by 3 desc;

#### Генерация списка таблиц в базе данных с самыми большими первыми и процентом времени, в течение которого они используют индекс

      SELECT 
        relname, 
        100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used, 
        n_live_tup rows_in_table
      FROM 
        pg_stat_user_tables
      WHERE 
          seq_scan + idx_scan > 0 
      ORDER BY 
        n_live_tup DESC;
        
        
