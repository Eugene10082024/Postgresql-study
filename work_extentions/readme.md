### Расширения в Postgresql

#### Информация по расширениям

    SELECT * FROM pg_extension; - вывод установленных расширений в БД

    SELECT * FROM pg_available_extensions; - вывод доступных расширений

#### Cоздание расширения в Postgres:

    CREATE EXTENSION hstore SCHEMA addons;

или:
    SET search_path = addons;
    CREATE EXTENSION hstore;


#### Изменить определение расширения:

    ALTER EXTENSION timescaledb UPDATE;
    ALTER EXTENSION hstore UPDATE TO '2.0';                                     - Обновление расширения hstore до версии 2.0
    ALTER EXTENSION hstore SET SCHEMA utils;                                    - Смена схемы расширения hstore на utils
    ALTER EXTENSION hstore ADD FUNCTION populate_record(anyelement, hstore);    - Добавление существующей функции в расширение hstore
    
    
#### Удаление расширения:

    DROP EXTENSION hstore; - Удаление расширения hstore из текущей базы данных. 
    

#### Postgresql.conf

Пример включения расширения в кластер Postgresql. После добавления расширения неоходима перезагрузка кластера Postgresql

**ВНИМАНИЕ:** Перед добавлением расширения оно должно быть установлено на сервер. В противном случае после отравки кластера Postgresql в rebbot он не стартанет.

    shared_preload_libraries = 'pg_stat_statements'

### Внешние расширения:

***Pg_repack*** - очистка таблиц без долгой блокировки таблицы.

***timescaleDB*** - для работы с временными рядами (time series)

Запросы по объектам расширения:

В запросах используется hypertable => history

        SELECT * FROM _timescaledb_internal.bgw_job_stat; - выполненные jobs timescaledb
        
        SELECT * FROM pg_catalog.pg_extension WHERE extname = 'timescaledb'
        SELECT * FROM timescaledb_information.hypertables
        SELECT * FROM timescaledb_information.chunks;
        SELECT * FROM timescaledb_information.chunks where hypertable_name='history';
        SELECT * FROM chunks_detailed_size('history');
        SELECT chunk_schema,chunk_name,compression_status  FROM chunk_compression_stats('history');
        SELECT show_chunks('history');
        SELECT chunk_schema, chunk_name, compression_status, before_compression_table_bytes, before_compression_index_bytes, before_compression_toast_bytes,          before_compression_total_bytes,after_compression_table_bytes, after_compression_index_bytes, after_compression_toast_bytes, after_compression_total_bytes,  node_name FROM chunk_compression_stats('history_txt')


