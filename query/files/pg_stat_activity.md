### Работа с pg_stat_activity

PostgreSQL RDBMS имеет очень информативные встроенные инструменты для отслеживания состояния базы данных. Одним из таких инструментов является pg_stat_activity.
Это системное представление, позволяющее отслеживать процессы баз данных в режиме реального времени. Это представление сравнимо с системной командой top, 
это одно из первых мест, с которых администратор базы данных может начать расследование в случае возникновения какой-либо проблемы. 
Далее будет приведено несколько полезных примеров, как это представление можно использовать для обнаружения аномальной активности. 
Для начала нам нужен только клиент postgresql, например psql.

Для начала можно использовать самый простой запрос:

      SELECT * FROM pg_stat_activity;

Не важно, к какой базе данных вы подключены, pg_stat_activity является общей для всех баз данных.

pg_stat_activity показывает одну строку для каждого соединения с базой данных. Для каждого соединения существует отдельный процесс UNIX. Для одного соединения есть несколько атрибутов:

***pid*** - идентификатор процесса, который обрабатывает соединение. В терминологии PostgreSQL этот процесс называется backend или worker.

***datid, datname***   - идентификатор и имя базы данных, к которой подключается клиент.

***useysid, usename*** - идентификатор и имя, которое использовалось для подключения.

***client_addr, client_port, client_hostname*** - сетевые настройки клиента, сетевой адрес, порт и имя хоста.

***application_name*** - произвольное имя, которое может быть указано, когда клиент подключается или переменная сеанса.

***backend_start, xact_start, query_start, state_change*** - отметки времени, которые указывают, когда был запущен процесс (backend), транзакция или запрос внутри транзакции, и когда в последний раз состояние процесса было изменено.

***state, waiting*** - состояние процесса и флаг, который указывает, ожидает ли процесс другого процесса.

***query*** - текст запроса, который в данный момент выполняется работником или был недавно выполнен в связи с этим.

Поскольку каждая строка описывает одно соединение, мы можем легко узнать, сколько клиентских соединений установлено с базой данных.

            SELECT count(*) AS total_conns FROM pg_stat_activity;
            total_conns 
            -------------
            61

Затем мы можем использовать предложение WHERE и добавить параметры фильтра. Например, мы можем увидеть, сколько соединений установлено с хоста с адресом 10.0.20.26.

            SELECT count(*) FROM pg_stat_activity WHERE client_addr = '10.0.20.26';
            count 
            -------
            10

Конечно, мы можем использовать разные условия и фильтровать другие поля, включая и комбинируя их с помощью AND и OR. Очень важными атрибутами являются время начала транзакции и запроса. Используя текущее время, мы можем рассчитать продолжительность транзакций и запросов. Это очень полезно для обнаружения длинных транзакций.

            SELECT
            client_addr, usename, datname,
            clock_timestamp() - xact_start AS xact_age,
            clock_timestamp() - query_start AS query_age,
            state, query
            FROM pg_stat_activity 
            ORDER BY coalesce(xact_start, query_start);
            
            -[ RECORD 1 ]-------------------------------------------------------
            client_addr | 10.0.20.26
            usename     | james
            datname     | sales_db
            xact_age    | 
            query_age   | 12 days 05:52:09.181345
            state       | idle
            query       | <query text>

Как мы видим из вывода, у нас есть запрос, который выполняется в течение 12 дней. Это не активная транзакция, потому что поле xact_age пустое. Используя поле state, мы можем выяснить состояние соединения - в настоящее время это idle соединение. Скорее всего, Джеймс выполнил какой-то запрос в пятницу, не отключился от базы данных и уехал в отпуск на две недели.

Как упоминалось выше, в этом примере мы используем поле state. Давайте рассмотрим это более подробно. Поле state определяет текущий статус соединения и может находиться в одном из нескольких состояний:

**active** - это рабочее состояние процесса означает, что процесс выполняет запрос, то есть выполняет полезную работу.

**Idle** - бездействующий, никакой полезной работы не делается.

**idle in transaction** - бездействующий в открытой транзакции. Это означает, что приложение открыло транзакцию и больше ничего не делает. Длительные транзакции (более одного часа) с таким статусом вредны для базы данных и должны быть принудительно закрыты, а причины такого поведения на уровне приложения должны быть устранены.

**idle in transaction (aborted)** - это прерванная транзакция, по крайней мере, один из запросов внутри транзакции был сбойным, а другие запросы будут игнорироваться, пока транзакция не будет прервана.

**fastpath function call**  - бэкэнд выполняет функцию fast-path.

**disabled** - это фиктивное состояние, оно отображается, только если опция track_activities отключена.

            SELECT
            client_addr, usename, datname, state, count(*)
            FROM pg_stat_activity 
            GROUP BY 1, 2, 3, 4 ORDER BY 5 DESC;

            client_addr  | usename  | datname  |        state        | count 
            -------------+----------+----------+---------------------+-------
            127.0.0.1    | app_user | sales_db | idle                | 28
            127.0.0.1    | app_user | sales_db | active              | 15
            127.0.0.1    | app_user | sales_db | idle in transaction | 3
            127.0.0.1    | bg_user  | sales_db | active              | 6
            10.11.2.12   | james    | sales_db | idle                | 2
            10.0.20.26   | helen    | shop_db  | active              | 1

Обратите внимание, что в приведенном выше примере большинство соединений простаивают. Если общее количество незанятых соединений составляет десятки или несколько сотен, то вам определенно нужно задуматься об использовании pgbouncer, чтобы уменьшить количество незанятых процессов. Мы также можем видеть незанятые процессы транзакций, важно следить за ними и закрывать их с помощью pg_terminate_backend (), если они зависают слишком долго. Определить возраст таких связей не составляет большой проблемы, потому что мы уже знаем, как это сделать.

            SELECT
            client_addr, usename, datname,
            clock_timestamp() - xact_start AS xact_age, 
            clock_timestamp() - query_start AS query_age,
            state, query
            FROM pg_stat_activity 
            WHERE state = 'idle in transaction' 
            ORDER BY coalesce(xact_start,query_start);

            client_addr | usename  | datname  |    xact_age     |    query_age    |        state        |   query
            ------------+----------+----------+-----------------+-----------------+---------------------+-------------
            127.0.0.1   | app_user | sales_db | 00:00:06.001629 | 00:00:00.002542 | idle in transaction | <query text>
            127.0.0.1   | app_user | sales_db | 00:00:05.006710 | 00:00:00.003561 | idle in transaction | <query text>
            127.0.0.1   | app_user | sales_db | 00:00:00.009004 | 00:00:00.001629 | idle in transaction | <query text>

Как мы видим, возраст транзакции относительно невелик, поэтому мы можем фильтровать короткие запросы. Также мы фильтруем пустые соединения, потому что они не так интересны. Давайте отфильтруем все, что быстрее 10 секунд.

            SELECT
            client_addr, usename, datname,
            now() - xact_start AS xact_age,
            now() - query_start AS query_age,
            state, query
            FROM pg_stat_activity 
            WHERE (
            (now() - xact_start) > '00:00:10'::interval OR 
            (now() - query_start) > '00:00:10'::interval AND
            state <> 'idle'
            ) 
            ORDER BY coalesce(xact_start, query_start);
            client_addr | usename  | datname  |    xact_age     |    query_age    |        state        |   query
            ------------+----------+----------+-----------------+-----------------+---------------------+-------------
            127.0.0.1   | app_user | sales_db | 00:00:12.013319 | 00:00:05.002151 | active              | <query text> 
            127.0.0.1   | app_user | sales_db | 00:00:10.083718 | 00:00:10.083718 | idle in transaction | <query text>

Но это не все, могут быть ситуации, когда запрос блокируется другим запросом или транзакцией. Для идентификации таких соединений можно использовать атрибут ожидания (true если отключено, false  если нет блокировок).

            SELECT
            client_addr, usename, datname,
            now() - xact_start AS xact_age,
            now() - query_start AS query_age,
            state, waiting, query
            FROM pg_stat_activity
            WHERE waiting
            ORDER BY coalesce(xact_start, query_start);

            client_addr | usename  |   datname  |    xact_age     |    query_age    | state  | waiting |   query
            ----------- +----------+------------+-----------------+-----------------+--------+---------+-------------
            127.0.0.1   | app_user |   sales_db | 00:00:16.736127 | 00:00:02.839100 | active |     t   | <query text> 


Наличие ожидающих процессов (waiting processes) — плохой признак, обычно это свидетельствует о плохом дизайне приложения. Блокировка возникает в ситуации, когда две или более параллельных транзакций (или запросов) пытаются получить доступ к одному и тому же ресурсу, например к набору строк таблицы. Простой пример: транзакция A обновляет набор строк M, а транзакция B пытается обновить тот же набор строк и будет ждать, пока транзакция A будет либо зафиксирована, либо прервана. Кроме pg_stat_activity такие ситуации можно отслеживать в логе postgresql, если включен log_lock_waits.

            [UPDATE waiting] LOG: process 29054 still waiting for ShareLock on transaction 2034635 after 1000.160 ms
            [UPDATE waiting] DETAIL: Process holding the lock: 29030. Wait queue: 29054.
            [UPDATE waiting] CONTEXT: while updating tuple (0,68) in relation "products"
            [UPDATE waiting] STATEMENT: update products set price = 20 where id = 1;
            [UPDATE waiting] LOG: process 29054 acquired ShareLock on transaction 2034635 after 9049.000 ms
            [UPDATE waiting] CONTEXT: while updating tuple (0,68) in relation "products"
            [UPDATE waiting] STATEMENT: update products set price = 20 where id = 1;

Что тут происходит?

1.Процесс с PID 29054 заблокирован и находится в ожидании. Процесс с PID 29030 удерживает блокировку. 

2.Текст ожидающего запроса также был зарегистрирован. 

3.После 9 секунд процесса получения ресурсов с PID 29054 удалось выполнить запрос.

Возможен и deadlock. Это происходит, когда для фиксации какой-либо транзакции PostgreSQL необходимо получить блокировку ресурса, в настоящее время заблокированного другой транзакцией, которая может снять блокировку только после получения еще одной блокировки ресурса, заблокированного в данный момент первой транзакцией. Когда возникает такая ситуация, механизм обнаружения взаимоблокировок postgres завершает одну из транзакций, что позволяет продолжить выполнение других транзакций. Время ожидания взаимоблокировки по умолчанию составляет 1 секунду и может быть настроено через deadlock_timeout. Такие ситуации также фиксируются в журнале postgresql.

            [UPDATE] ERROR: deadlock detected
            [UPDATE] DETAIL: Process 29054 waits for ShareLock on transaction 2034637; blocked by process 29030.
            Process 29030 waits for ShareLock on transaction 2034638; blocked by process 29054.
            Process 29054: update products set price = 20 where id = 1;
            Process 29030: update products set price = 20 where id = 2;
            [UPDATE] HINT: See server log for query details.
            [UPDATE] CONTEXT: while updating tuple (0,68) in relation "products"
            [UPDATE] STATEMENT: update products set price = 20 where id = 1;
            [UPDATE waiting] LOG: process 29030 acquired ShareLock on transaction 2034638 after 2924.914 ms
            [UPDATE waiting] CONTEXT: while updating tuple (0,69) in relation "products"
            [UPDATE waiting] STATEMENT: update products set price = 20 where id = 2;

Что происходит здесь

1.Процесс с PID 29054 ожидает, так как он был заблокирован процессом с PID 29030. 

2.В свою очередь, процесс с PID 29030 тоже ждет, так как он был заблокирован процессом с PID 29054. 

3.Мы видим дальнейшие запросы, из-за которых возникла взаимоблокировка. 

4.Процесс с PID 29030 был разблокирован, поэтому запрос в процессе 29054 был принудительно отменен, а транзакция переведена в состояние «ожидание в транзакции (прервано)».

В любом случае, ожидающие процессы и дедлоки (waiting processes and deadlocks) — это плохо, такие инциденты нужно расследовать и устранять. Может быть, кто-то спросит: Почему они такие плохие? Отвечу, пока процесс заблокирован, приложение, отправившее запрос, тоже ждет, в этом случае конечный пользователь может подумать, что система тормозит и может расстроиться. Никто не любит долгое время отклика. В заключение, теперь вы знаете, как эффективно использовать pg_stat_activity, и можете создать собственное представление. Это будет первый помощник, когда что-то в базе данных выйдет из-под контроля. Вот пример представления, которое показывает аномальную активность в базе данных.

            CREATE VIEW db_activity AS
            SELECT
            pid, client_addr, client_port,
            datname, usename,
            clock_timestamp() - pg_stat_activity.xact_start AS ts_age,
            clock_timestamp() - pg_stat_activity.query_start AS query_age,
            clock_timestamp() - pg_stat_activity.state_change AS change_age,
            waiting, state, query
            FROM pg_stat_activity
            WHERE (
            (clock_timestamp() - xact_start) > '00:00:00.1'::interval OR
            (clock_timestamp() - query_start) > '00:00:00.1'::interval
            AND state IN ('idle in transaction (aborted)', 'idle in transaction')
            ) AND pid <> pg_backend_pid()
            ORDER BY COALESCE (xact_start, query_start);




