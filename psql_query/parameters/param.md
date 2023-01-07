### Работа с параметрами базы данных

#### Где размещены параметры кластера 

***pg_controldata*** 

    /usr/pgsql-12/bin/pg_controldata -D $PGDATA - просмотр текущих параметров кластера
    
***postgresql.conf***  - основной конфигурационный файл Postgresql

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

Ключевые столбцы представления pg_settings:

    name, setting, unit — название и значение параметра;
    boot_val — значение по умолчанию;
    reset_val — значение, которое восстановит команда RESET;
    source — источник текущего значения параметра;
    pending_restart — значение изменено в файле конфигурации, но для применения требуется перезапуск сервера.

Столбец context определяет действия, необходимые для применения параметра. Среди возможных значений:

    internal — изменить нельзя, значение задано при установке;
    postmaster — требуется перезапуск сервера;
    sighup — требуется перечитать файлы конфигурации,
    superuser — суперпользователь может изменить для своего сеанса;
    user — любой пользователь может изменить для своего сеанса.

[Полное описание представления](https://postgrespro.ru/docs/postgresql/14/view-pg-settings)

#### Примеры:

        select name, setting, context from pg_settings where category like '%name_category%';

        select name,setting,context,pending_restart from pg_settings where category like '%Write-Ahead Log%'; 
        
        select * from pg_settings where name like 'max_connections'\gx;

Запрос,  определяет имя и значение для каждого параметра, который можно изменить только путем перезапуска postgreSQL

        SELECT name, setting  FROM pg_settings WHERE context = 'postmaster' 
 
 Запрос, чтобы получить список только тех настроек, которые не изменились по сравнению со значениями по умолчанию и требуют перезагрузки
 
        SELECT name, setting, boot_val FROM pg_settings WHERE context = 'postmaster' AND boot_val = setting;
 
 Получение списка категорий:
 
        select distinct category from pg_settings;
           
