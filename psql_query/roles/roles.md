### Роли в Postgresql

#### Ссылки на описание представлений:

[pg_roles - информации о ролях в базах данных](https://postgrespro.ru/docs/enterprise/14/view-pg-roles)

[pg_authid - информация об идентификаторах для авторизации](https://postgrespro.ru/docs/enterprise/14/catalog-pg-authid)

Oсобенность pg_authid:

Столбец rolpassword - Пароль (возможно зашифрованный); NULL, если он не задан. Его формат зависит от используемого вида шифрования. 

#### Дополнительные ссылки

[Членство в роли](https://postgrespro.ru/docs/enterprise/14/role-membership)

#### Создание пользователя:

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
    
[Предопределённые роли](https://postgrespro.ru/docs/enterprise/14/predefined-roles)

#### Дополнительная информация

На уровне ролей можно устанавливать многие конфигурационные параметры времени выполнения.

Например, если по некоторым причинам всякий раз при подключении к базе данных требуется отключить использование индексов можно выполнить:

    ALTER ROLE myname SET enable_indexscan TO off;

Для удаления установок на уровне ролей для параметров конфигурации используется 

    ALTER ROLE имя_роли RESET имя_переменной. 











    
    

    
