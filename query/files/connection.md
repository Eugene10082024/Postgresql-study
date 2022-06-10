### Запросы и Соединения

Вывод количества соединений в кластере Postgresql

      SELECT count(*) AS total_conns FROM pg_stat_activity;
      
Вывод количества соединений от определенного клиента

      SELECT count(*) FROM pg_stat_activity WHERE client_addr = '10.0.20.26';
      
Вывод статистики по выполняемым соединениям:

      SELECT client_addr, usename, datname, state, count(*) FROM pg_stat_activity GROUP BY 1, 2, 3, 4 ORDER BY 5 DESC;

Вывод списка активных запросов 

      SELECT * FROM pg_stat_activity WHERE state = 'active';

Вежливо попросить запрос завершиться

      SELECT pg_cancel_backend(<pid of the process>)
     
где pid of the process находим из предыдущего запроса 
      
Убить зависший запрос:

      SELECT pg_terminate_backend(<pid of the process>)
