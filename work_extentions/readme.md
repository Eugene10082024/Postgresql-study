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
    
    ALTER EXTENSION hstore UPDATE TO '2.0';                                     - Обновление расширения hstore до версии 2.0
    ALTER EXTENSION hstore SET SCHEMA utils;                                    - Смена схемы расширения hstore на utils
    ALTER EXTENSION hstore ADD FUNCTION populate_record(anyelement, hstore);    - Добавление существующей функции в расширение hstore
    
    
#### Удаление расширения:

    DROP EXTENSION hstore; - Удаление расширения hstore из текущей базы данных. 
    

#### Postgresql.conf

    shared_preload_libraries = 'pg_stat_statements'

### Внешние расширения:

***Pg_repack*** - очистка таблиц без долгой блокировки таблицы.

***timescaleDB*** - для работы с временными рядами (time series)

