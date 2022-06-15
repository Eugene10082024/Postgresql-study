### Получение информации по базе данных

#### Вывод размеров БД в кластере 

    select datname, pg_size_pretty(pg_database_size(datname)) from pg_database
