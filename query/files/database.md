### Получение информации по базе данных

#### Вывод размеров БД в кластере 

    SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database
