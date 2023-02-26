### Запросы для работы с таблицами

1. [Вывод размера таблиц вместе с индексами](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/query/files/tables.md#%D0%B2%D1%8B%D0%B2%D0%BE%D0%B4-%D1%80%D0%B0%D0%B7%D0%BC%D0%B5%D1%80%D0%B0-%D1%82%D0%B0%D0%B1%D0%BB%D0%B8%D1%86-%D0%B2%D0%BC%D0%B5%D1%81%D1%82%D0%B5-%D1%81-%D0%B8%D0%BD%D0%B4%D0%B5%D0%BA%D1%81%D0%B0%D0%BC%D0%B8) 
2. [Вывод таблиц с наибольшим количеством мертвых строк (tuples)](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/query/files/tables.md#%D0%B2%D1%8B%D0%B2%D0%BE%D0%B4-%D1%82%D0%B0%D0%B1%D0%BB%D0%B8%D1%86-%D1%81-%D0%BD%D0%B0%D0%B8%D0%B1%D0%BE%D0%BB%D1%8C%D1%88%D0%B8%D0%BC-%D0%BA%D0%BE%D0%BB%D0%B8%D1%87%D0%B5%D1%81%D1%82%D0%B2%D0%BE%D0%BC-%D0%BC%D0%B5%D1%80%D1%82%D0%B2%D1%8B%D1%85-%D1%81%D1%82%D1%80%D0%BE%D0%BA-tuples)
3. [Генерация списка таблиц в базе данных с самыми большими индексами и процентом времени, в течение которого они используют индекс](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/query/files/tables.md#%D0%B3%D0%B5%D0%BD%D0%B5%D1%80%D0%B0%D1%86%D0%B8%D1%8F-%D1%81%D0%BF%D0%B8%D1%81%D0%BA%D0%B0-%D1%82%D0%B0%D0%B1%D0%BB%D0%B8%D1%86-%D0%B2-%D0%B1%D0%B0%D0%B7%D0%B5-%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85-%D1%81-%D1%81%D0%B0%D0%BC%D1%8B%D0%BC%D0%B8-%D0%B1%D0%BE%D0%BB%D1%8C%D1%88%D0%B8%D0%BC%D0%B8-%D0%B8%D0%BD%D0%B4%D0%B5%D0%BA%D1%81%D0%B0%D0%BC%D0%B8-%D0%B8-%D0%BF%D1%80%D0%BE%D1%86%D0%B5%D0%BD%D1%82%D0%BE%D0%BC-%D0%B2%D1%80%D0%B5%D0%BC%D0%B5%D0%BD%D0%B8-%D0%B2-%D1%82%D0%B5%D1%87%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BE%D1%82%D0%BE%D1%80%D0%BE%D0%B3%D0%BE-%D0%BE%D0%BD%D0%B8-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D1%83%D1%8E%D1%82-%D0%B8%D0%BD%D0%B4%D0%B5%D0%BA%D1%81)
4. Show database bloat (распухание БД)
5. Поиск таблицы которой соотвествует определенная TOAST таблица

#### Вывод размера таблиц вместе с индексами

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


#### Вывод таблиц с наибольшим количеством мертвых строк (tuples)

      select relname, n_live_tup, n_dead_tup from pg_stat_all_tables order by 3 desc;

#### Генерация списка таблиц в базе данных с самыми большими индексами и процентом времени, в течение которого они используют индекс

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
        
  
  #### Show database bloat
https://wiki.postgresql.org/wiki/Show_database_bloat

      SELECT
        current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
        ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::float/otta END)::numeric,1) AS tbloat,
        CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
        iname, /*ituples::bigint, ipages::bigint, iotta,*/
        ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::float/iotta END)::numeric,1) AS ibloat,
        CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes
      FROM (
        SELECT
          schemaname, tablename, cc.reltuples, cc.relpages, bs,
          CEIL((cc.reltuples*((datahdr+ma-
            (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)) AS otta,
          COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
          COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
        FROM (
          SELECT
            ma,bs,schemaname,tablename,
            (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
            (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
          FROM (
            SELECT
              schemaname, tablename, hdr, ma, bs,
              SUM((1-null_frac)*avg_width) AS datawidth,
              MAX(null_frac) AS maxfracsum,
              hdr+(
                SELECT 1+count(*)/8
                FROM pg_stats s2
                WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
              ) AS nullhdr
            FROM pg_stats s, (
              SELECT
                (SELECT current_setting('block_size')::numeric) AS bs,
                CASE WHEN substring(v,12,3) IN ('8.0','8.1','8.2') THEN 27 ELSE 23 END AS hdr,
                CASE WHEN v ~ 'mingw32' THEN 8 ELSE 4 END AS ma
              FROM (SELECT version() AS v) AS foo
            ) AS constants
            GROUP BY 1,2,3,4,5
          ) AS foo
        ) AS rs
        JOIN pg_class cc ON cc.relname = rs.tablename
        JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = rs.schemaname AND nn.nspname <> 'information_schema'
        LEFT JOIN pg_index i ON indrelid = cc.oid
        LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
      ) AS sml
      ORDER BY wastedbytes DESC

#### Поиск таблицы которой соотвествует определенная TOAST таблица

1. Вывод таблиц, которые занимают наибольшее место на диске.

            SELECT nspname || '.' || relname AS "relation",
                pg_size_pretty(pg_relation_size(C.oid)) AS "size"
              FROM pg_class C
              LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
              WHERE nspname NOT IN ('pg_catalog', 'information_schema')
              ORDER BY pg_relation_size(C.oid) DESC
              LIMIT 20;

Выводится 20 таблиц. Ниже пример вывода.

                        relation             |  size
            ----------------------------------+---------
             pg_toast.pg_toast_30748420       | 337 GB
             pg_toast.pg_toast_30748420_index | 6280 MB
             public._reference197718          | 4679 MB
             pg_toast.pg_toast_6439977        | 1958 MB
             public._reference197718_3        | 1790 MB
             public._inforg273494             | 635 MB
             public._inforgchngr296362_1      | 422 MB
             public._inforgchngr296362_2      | 385 MB
             public._inforg274543             | 366 MB
             public._inforgchngr296362        | 303 MB
             public._reference197718_s_hpk    | 260 MB
             public._reference197718_2        | 240 MB
             public._inforg271706             | 234 MB
             public._inforg286642             | 228 MB
             public._referencechngr296742_1   | 213 MB
             public._reference197718_1        | 201 MB
             public._referencechngr296742_2   | 187 MB
             pg_toast.pg_toast_6633348        | 183 MB
             public._reference197718_vt297219 | 150 MB
             public._referencechngr296742     | 143 MB
            (20 rows)
            
2. Запоминаем из первой строки - pg_toast_30748420. Данное значение будет использовано в последующих скриптах.

3. Выполняем следующий запрос с подстановкой значения на выбор:

name_toast_table - имя toast таблицы для которой надо найти родительскую таблицу
	
Например - pg_toast_30748420

##### Первый запрос

            select n.nspname, c.relname
            from pg_class c
            inner join pg_namespace n on c.relnamespace = n.oid
            where reltoastrelid = (
                select oid
                from pg_class
                where relname = 'name_toast_table'
                and relnamespace = (SELECT n2.oid FROM pg_namespace n2 WHERE n2.nspname = 'pg_toast') );
   
  Результат вывода:
   
             nspname |     relname
            ---------+------------------
             public  | _reference197718
            (1 row)

###### Второй запрос:

             SELECT
                c1.relname,
                c2.relname AS toast_relname
            FROM
                pg_class c1
                JOIN pg_class c2 ON c1.reltoastrelid = c2.oid
            WHERE
                c2.relname ='name_toast_table'
                AND c1.relkind = 'r';
	
Результат вывода:

                 relname      |   toast_relname
            ------------------+-------------------
             _reference197718 | pg_toast_30748420
            (1 row)



