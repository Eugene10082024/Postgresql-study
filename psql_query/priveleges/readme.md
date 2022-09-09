### Привелегии в Postgresql

Просмотр GRANT для конкретной роли

    SELECT table_schema as schema, table_name as table, privilege_type as privilege FROM information_schema.table_privileges WHERE grantee='readonly';
    
Пользователь будет подключен к базе данных и получит все права для работы с ней

	GRANT CONNECT ON DATABASE postgres TO postgres;
	
все команды, примененные к таблице, были доступны пользователю

	GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO postgres;
	GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
	GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
	GRANT ALL PRIVILEGES ON DATABASE postgres TO postgres;
	
Назначение привелений на создаваемые объекты:

	ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO postgres;	
	

#### Дополнительные статьи
[PostgreSQL: Give all permissions to a user on a PostgreSQL database](
https://stackoverflow.com/questions/22483555/postgresql-give-all-permissions-to-a-user-on-a-postgresql-database)

[Настройка интеграции ADB и LDAP](https://docs.arenadata.io/adb/ldap/config.html)

[Postgresql: what does GRANT ALL PRIVILEGES ON DATABASE do?]
