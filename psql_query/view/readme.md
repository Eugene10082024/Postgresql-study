### Работа с представлениями

Представление - по факту это именнованный запрос. Он нам нужен тогда, когда мы не хотим много раз писать запрос, а будем подключаться к нему по имени.

Создание представления:

    CREATE VIEW select_all_from_users AS SELECT * FROM users;

Обращение к представлению:

    SELECT * FROM select_all_from_users;
    
 Просмотр созданных представлений в БД:

    \dv
    
или

    SELECT table_name FROM INFORMATION_SCHEMA.tables WHERE table_type='VIEW' AND table_schema=ANY(current_schemas(false)) ORDER BY table_name;
