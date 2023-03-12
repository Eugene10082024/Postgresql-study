### PSQL

[Основы psql](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql/readme.md#%D0%BE%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-psql)

[команды psql](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql/readme.md#%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4%D1%8B-psql)

[Просмотр relations (tables, views,indexes ...)](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql/readme.md#%D0%BF%D1%80%D0%BE%D1%81%D0%BC%D0%BE%D1%82%D1%80-relations-tables-viewsindexes-)

[Работа с переменными](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql/readme.md#%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0-%D1%81-%D0%BF%D0%B5%D1%80%D0%B5%D0%BC%D0%B5%D0%BD%D0%BD%D1%8B%D0%BC%D0%B8)

[Взаимодействие с ОС](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql/readme.md#%D0%B2%D0%B7%D0%B0%D0%B8%D0%BC%D0%BE%D0%B4%D0%B5%D0%B9%D1%81%D1%82%D0%B2%D0%B8%D0%B5-%D1%81-%D0%BE%D1%81)

[Запуск команд](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql/readme.md#%D0%B7%D0%B0%D0%BF%D1%83%D1%81%D0%BA-%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4)

[Настройка PSQL](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql/readme.md#%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0-psql)

### Основы psql

psql --help

Строка подключения к БД postgresql:

    psql -d <name_database> -h <host> -p <port> -U <user>

    psql -v name=value - указание переменной при запуске psql
    
По умолчанию port 5432

Общий системный файл называется psqlrc и располагается в каталоге /usr/local/pgsql/etc при обычной сборке из исходных кодов.

Расположение этого каталога можно узнать командой:

    pg_config --sysconfdir.

Пользовательский файл находится в домашнем каталоге пользователя ОС и называется .psqlrc. Его расположение можно изменить, задав
переменную окружения PSQLRC.

В эти файлы можно записать команды, настраивающие psql — например, изменить приглашение, включить вывод времени выполнения команд и т. п.

История команд сохраняется в файле .psql_history в домашнем каталоге пользователя. 
Расположение этого файла можно изменить, задав переменную окружения PSQL_HISTORY или переменную psql HISTFILE. 
По умолчанию хранится 500 последних команд; это число можно изменить переменной psql HISTSIZE.
Пролистывать историю команд можно стрелками вверх и вниз, искать с помощью Ctrl+R — доступен весь набор команд, предлагаемых readline

Описание настройки приглашения в документации: https://postgrespro.ru/docs/postgresql/10/app-psql.html#app-psql-prompting

### Команды psql

**\с <name_database>** - переключение на БД (name_database)

\c или \connect [ -reuse-previous=on|off ] [ имя_бд [ имя_пользователя ] [ компьютер ] [ порт ] | строка_подключения ]

Примеры:

    => \c mydb myuser host.dom 6432
    => \c service=foo
    => \c "host=localhost port=5432 dbname=mydb connect_timeout=10 sslmode=disable"
    => \c -reuse-previous=on sslmode=require    -- меняется только sslmode
    => \c postgresql://tom@localhost/mydb?application_name=myapp

**\?** - вывод списка команд psql

**\? variables** - вывод списка переменных psql

**\h** - вывод списка команд PostgreSQL

**\h select** - вывод подсказки по команде select

**\x** - переключение в расширенный режим вывода или возврат обратно

**\conninfo** - просмотр подключения к серверу postgres

**\! <name_command>** - использование команд shell

**\cd <путь>** - переход в другой каталог OC из psql

**\i <name_script>** - запуск скрипта в psql

**\e <name_file>** - редактирование файла в psql

**\a** - вывод без выравнивания

**\t** - вывод без заголовка

**\p** - просмотр содержимого буфера psql

**\g** - выполнение повторно команды из буфера

**\w <file>** - запись буфера в файл
  
**\r** - очиска буфера
  
**\gx** - установка после запроса выводит результаты в разширенном виде
  
**\timing on** - отображение времени выполнения запроса в консольной утилите PostgreSQL
    
**\o <name_file>** - весь вывод попадает в файл с именем name_file

**\set ECHO_HIDDEN on** - для просмотра что у нас под копотом, чтобы посмотреть какие запросы спрятаны в psql

### Просмотр relations (tables, views,indexes ...)
    
**\d** - вывод всех relations в БД
    
**\dt** - вывод списка таблиц в БД
    
**\dtS+** - 
    
**\dp+** - вывод прав у ролей
    
**\dx** - вывод установленных разширений
    
**\df** - вывод списка функций
    
**\dn** - вывод списка схем в БД. Не выводит системные схемы
    
**\dn+ <имя_схемы>** - выводит привелегии на схему
    
**\db** - вывод списка табличных пространств 
    
**\dpp** - вывод настроек DEFAULT PRIVILEGES
    
**\dRp+** - вывод всех имеющихся публикаций на сервере
    
**\dRs** - вывод имеющихся подписок на сервере
    
**\dcS** - вывод списка доступных перекодировок (\dcS *koi8* - вывод доступных перекодировок для koi8)
    
**\dOS+ ru** - вывод правил сортировки для русского языка 
    
**\dp mytable** - вывод существующих прав, назначенных для таблицы и столбцов metable
    
### Работа с переменными
    
 **\set** - вывод значений переменных в psql
    
По аналогии с shell, psql имеет собственные переменные, среди которых есть ряд встроенных (имеющих определенный смысл для psql).
    
Установим переменную:
    
        \set TEST Hi!
    
Чтобы получить значение, надо предварить имя переменной двоеточием:
    
        \echo :TEST
        Hi!
    
Значение переменной можно сбросить:
    
        \unset TEST
        \echo :TEST
        :TEST
    
Можно результат запроса записать в переменную. Для этого запрос нужно завершить командой \gset вместо ";":
    
        SELECT now() AS curr_time \gset
        \echo :curr_time
        2019-03-31 15:25:23.68208+03
    
Запрос должен возвращать только одну запись.   
    
### Взаимодействие с ОС   
    
**\! <name_command>** - использование команд shell

Пример:
    
    \! pwd
    \! uptime
    
Можно установить переменную окружения:
    
    \setenv TEST Hello
    \! echo $TEST    
    
### Запуск команд
 
**\i <name_script>** -запуск скрипта
    
**psql <name_script>**  - запуск скрипта
    
**psql -f <name_script>** - запуск скрипта
    
**psql -c 'command'** - выполнение команды psql

выполнение команды в базе dbname    
    
        psql -U postgres -d dbname -c "CREATE TABLE test(some_id serial PRIMARY KEY, some_text text);" 
    
вывод результата запроса в html-файл    
    
        psql -d dbname -H -c "SELECT * FROM test" -o test.html 
    
### Настройка PSQL

Настройка постраничного просмотра в .psqlrc 
    
        postgres$ echo "\setenv PAGER 'less -XS'" >> ~/.psqlrc
    
Печать времени выполнения 
    
        postgres$ echo "\timing on" >> ~/.psqlrc
    
Настройка приглашения 
    
Для добавления информации о роли нужно в начало переменных PROMPT1 и PROMPT2 добавить %n@ 
    
        postgres$ echo "\set PROMPT1 '%n@%/%R%# '" >> ~/.psqlrc
        postgres$ echo "\set PROMPT2 '%n@%/%R%# '" >> ~/.psqlrc

    
pgcli утилита командной строки с авто-дополнениям и подсветкой синтаксиса.    
    
      
    
    
