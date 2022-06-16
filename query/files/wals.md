### Работа с WAL файлами

    postgres=# select * from pg_ls_waldir() order by name;
    
    postgres=# select * from pg_ls_waldir() order by modification desc;
