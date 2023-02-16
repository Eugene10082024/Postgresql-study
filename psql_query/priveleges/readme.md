### Привелегии в Postgresql

Просмотр GRANT для конкретной роли

    SELECT table_schema as schema, table_name as table, privilege_type as privilege FROM information_schema.table_privileges WHERE grantee='readonly';
    
Пользователь будет подключен к базе данных и получит все права для работы с ней

	GRANT CONNECT ON DATABASE postgres TO postgres;

Предоставление права на работу со схемой пользщвателю

	GRANT USAGE ON SCHEMA public TO <user_login>;


Все команды, примененные к таблице, были доступны пользователю

	GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO postgres;
	GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
	GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
	GRANT ALL PRIVILEGES ON DATABASE postgres TO postgres;
	
Предоставление права пользователю на просмотр отдельной таблицы 
	
	GRANT SELECT ON TABLE <name_table> TO <user_login>;

Что надо сделать, чтобы у пользователя user было право выбирать данные из public.table_1 базы данных database_1

	GRANT CONNECT ON DATABASE database_1 TO user;
	/c database_1;
	GRANT USAGE ON SCHEMA public TO <user;
	GRANT SELECT ON TABLE public.table_1 TO user;


Назначение привелений на создаваемые объекты:

	ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO postgres;	

#### Запросы для вывода назначенных привелений

Вывод списка всех схем с привелегиями для текущего пользователя:

	WITH "names"("name") AS (
	  SELECT n.nspname AS "name"
	    FROM pg_catalog.pg_namespace n
	      WHERE n.nspname !~ '^pg_'
		AND n.nspname <> 'information_schema'
	) SELECT "name",
	  pg_catalog.has_schema_privilege(current_user, "name", 'CREATE') AS "create",
	  pg_catalog.has_schema_privilege(current_user, "name", 'USAGE') AS "usage"
	    FROM "names";

Вывод списка привелений:
	SELECT grantor, grantee, table_schema, table_name, privilege_type
	FROM information_schema.table_privileges;
	
Вывод списка привелегий для пользователя user:

	SELECT grantor, grantee, table_schema, table_name, privilege_type
	FROM information_schema.table_privileges
	WHERE grantee = 'user';

#### Дополнительные статьи
[PostgreSQL: Give all permissions to a user on a PostgreSQL database](
https://stackoverflow.com/questions/22483555/postgresql-give-all-permissions-to-a-user-on-a-postgresql-database)

[Настройка интеграции ADB и LDAP](https://docs.arenadata.io/adb/ldap/config.html)

[Postgresql: what does GRANT ALL PRIVILEGES ON DATABASE do?]
