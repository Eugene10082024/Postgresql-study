### Получение информации по базе данных

Вывод размеров БД в кластере 

    SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database;
    
Просмотр свойств баз данных:

    SELECT * from pg_database;
    
Просмотр свойств конкретной базы данных:
    
    SELECT * FROM pg_database WHERE datname ='name_db';
    
    
### Дополнительная информация:

[Описание представления pg_database](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/query/files/views/pg_database.md)
