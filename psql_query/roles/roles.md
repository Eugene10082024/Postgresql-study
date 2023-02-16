#### Роли в Postgresql

Создание пользователя:

    create user usr_old with password ‘user’;
    
При создании пользователя командой CREATE USER, соданный пользователь по умолчанию может логиниться с наружи и имеет разрешение LOGIN.
Пользователь созданный CREATE ROLE такого не имеет.

Роль принадлежит кластеру.

Смена пользователя (роли) в psql:
    
    SET ROLE <name_role>

Проверка текущей роли:

    SELECT current_user;

#### Права пользователя (роли)

    \du+
    
Использование схемы information_schema и запрос таблицы table_privileges:

    SELECT * FROM information_schema.table_privileges LIMIT 5;
    
вывод привелегий для конкретного пользователя (роли):

     SELECT * from information_schema.table_privileges WHERE grantee = ‘postgres’ LIMIT 5;

#### Предъопределенные роли в Postgresql   
    
    
    
    

    
