### Привелегии в Postgresql

Просмотр GRANT для конкретной роли

    SELECT table_schema as schema, table_name as table, privilege_type as privilege FROM information_schema.table_privileges WHERE grantee='readonly';
