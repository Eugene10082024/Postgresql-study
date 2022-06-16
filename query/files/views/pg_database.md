### Описание полей представления pg_database

        zabbix=# \d pg_database;
                                 Таблица "pg_catalog.pg_database"
            Столбец    |    Тип    | Правило сортировки | Допустимость NULL | По умолчанию 
        ---------------+-----------+--------------------+-------------------+--------------
         oid           | oid       |                    | not null          | 
         datname       | name      |                    | not null          | 
         datdba        | oid       |                    | not null          | 
         encoding      | integer   |                    | not null          | 
         datcollate    | name      |                    | not null          | 
         datctype      | name      |                    | not null          | 
         datistemplate | boolean   |                    | not null          | 
         datallowconn  | boolean   |                    | not null          | 
         datconnlimit  | integer   |                    | not null          | 
         datlastsysoid | oid       |                    | not null          | 
         datfrozenxid  | xid       |                    | not null          | 
         datminmxid    | xid       |                    | not null          | 
         dattablespace | oid       |                    | not null          | 
         datacl        | aclitem[] |                    |                   | 
        Индексы:
            "pg_database_datname_index" UNIQUE, btree (datname), табл. пространство "pg_global"
            "pg_database_oid_index" UNIQUE, btree (oid), табл. пространство "pg_global"
        Табличное пространство: "pg_global"

iod - Идентификатор строки

datname - Имя базы данных

datdba -  oid владелеца базы данных, обычно пользователь, создавший её

encoding  - кодировка символов для этой базы данных (pg_encoding_to_char() может преобразовать этот номер в имя кодировки)

datcollate - LC_COLLATE для этой базы данных

datctype - LC_CTYPE для этой базы данных

datistemplate - Если true, базу данных сможет клонировать любой пользователь с правами CREATEDB; в противном случае клонировать эту базу смогут только суперпользователи и её владелец

datallowconn - Если false, никто не сможет подключаться к этой базе данных. Это позволяет защитить базу данных template0 от модификаций.

datconnlimit - Задаёт максимально допустимое число одновременных подключений к этой базе данных. С -1 ограничения нет.

datlastsysoid - Последний системный OID в базе данных; в частности, полезен для pg_dump

datfrozenxid - Все идентификаторы транзакций, предшествующие данному, в этой базе данных заменены постоянным («замороженным») идентификатором транзакции. 
               Это нужно для определения, когда требуется очищать базу данных для сокращения объёма pg_xact. Это значение вычисляется как минимум значений pg_class.relfrozenxid для всех таблиц.
               
datminmxid -   Идентификаторы мультитранзакций, предшествующие данному, в этой базе данных заменены другим идентификатором транзакции. Это нужно для определения, когда требуется очищать базу данных для сокращения объёма pg_multixact. Это значение вычисляется как минимум значений pg_class.relminmxid для всех таблиц.

dattablespace - Табличное пространство по умолчанию для данной базы данных. Если таблица базы находится в этом пространстве, для неё значение pg_class.reltablespace будет нулевым; в частности, в нём окажутся все частные системные каталоги этой базы.

datacl - Права доступа

