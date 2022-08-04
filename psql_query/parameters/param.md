### Работа с параметрами базы данных

#### Где размещены параметры кластера Postgresql.conf

***pg_controldata*** 

    /usr/pgsql-12/bin/pg_controldata -D $PGDATA - просмотр текущих параметров кластера
    
***postgresql.conf*** 

***postgres.auto.conf*** - - хранятся результаты команды alter system. Этот файл ручками не правим.

#### Просмотр установленного значения параметра.

    postgres=# show <name_parameter>;
    
    

    
#### Применение измененных значений параметров

***pg_reload_conf()*** - применение изменений конфигурационных параметров на лету, тех которые можно применить

    postgres=# select pg_reload_conf();
    pg_reload_conf 
    ----------------
        t
    (1 строка)

    
#### Представления для работы с параметрами

***pg_settings*** - позволяет получить некоторые свойства каждого параметра, которые нельзя получить непосредственно, используя команду SHOW, например, минимальные и максимальные значения.

В данном представлении есть параметр - pending_restart . Если f - то норм, если t - то требует перезагрузки кластера.

[Полное описание представления](https://postgrespro.ru/docs/postgresql/14/view-pg-settings)

Пример:

        select name, setting, context from pg_settings where category like '%name_category%';

        select name,setting,context,pending_restart from pg_settings where category like '%Write-Ahead Log%'; 
        
        select * from pg_settings where name like 'max_connections'\gx;
 
 Получение списка категорий:
 
        select distinct category from pg_settings;
           
