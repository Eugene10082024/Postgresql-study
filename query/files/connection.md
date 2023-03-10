### Получение информации по соединениям

Вывод количества соединений в кластере Postgresql

      SELECT count(*) AS total_conns FROM pg_stat_activity;
      SELECT count(*) FROM pg_stat_activity
      
Вывод количества соединений от определенного клиента

      SELECT count(*) FROM pg_stat_activity WHERE client_addr = '10.0.20.26';
      SELECT count(*) as connections, usename FROM pg_stat_activity GROUP BY usename ORDER BY count(*) desc;
      
Вывод статистики по выполняемым соединениям:

      SELECT client_addr, usename, datname, state, count(*) FROM pg_stat_activity GROUP BY 1, 2, 3, 4 ORDER BY 5 DESC;
      
### Получение информации по сессиям и запросам    
      
 Вывод информации о состоянии сессий:
 
      SELECT datname,usename,client_addr,wait_event,state FROM pg_stat_activity;
      
 Вывод зависших сессий
 
       SELECT count(datname),datname 
       FROM pg_stat_activity 
       WHERE state like 'idle in%' AND ( current_timestamp - state_change ) > interval '1 minute' 
       AND datid NOT IN ( SELECT oid FROM pg_database WHERE datistemplate ) 
       GROUP BY datname;

Вывод списка активных запросов 

      SELECT * FROM pg_stat_activity WHERE state = 'active';
      
Поиск длительных запросов выполняемых в БД

      SELECT max(now() - xact_start) FROM pg_stat_activity WHERE state IN ('idle in transaction', 'active')
      
### Команды по завершению запросов        

Вежливо попросить запрос завершиться

      SELECT pg_cancel_backend(<pid of the process>)
     
где pid of the process находим из предыдущего запроса 
      
Убить зависший запрос:

      SELECT pg_terminate_backend(<pid of the process>)

### Ограничение по подключениям

к базе данных:

      ALTER DATABASE <name_db> CONNECTION LIMIT 0; (суперпользователи доступ будут иметь)
      ALTER DATABASE <name_db> CONNECTION LIMIT -1 - снятие ограничения на подключение к БД
      
ограничение подключения пользователя (роли)

      ALTER USER <name_user> CONNECTION LIMIT 0
      ALTER USER <name_user> CONNECTION LIMIT 0 - ограничение пользователя в одно подключение
      ALTER USER <name_user> CONNECTION LIMIT -1 - снятие ограничений на подключение
      
### Отключить всех клиентов от БД в PostgreSQL

      SELECT pg_terminate_backend(pg_stat_activity.pid) 
      FROM pg_stat_activity 
      WHERE pg_stat_activity.datname = current_database() AND pid <> pg_backend_pid();
      
### Запретить и разрешить подключения      

      UPDATE pg_database SET datallowconn = false WHERE datname = 'my_database';
      
      UPDATE pg_database SET datallowconn = true WHERE datname = 'my_database';

