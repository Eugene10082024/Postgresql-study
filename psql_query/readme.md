### Запросы для работы с Postgresql 
[1. База данных](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/database/database.md)

[2. Параметры базы данных](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/parameters/param.md)

[3. pg_hba.conf](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/pg_hba/pg_hba.md)

[4. Схемы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/schemas/schemas.md)

[5. Табличные пространства](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/tbs/tablespace.md)

[6. Таблицы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/tables/tables.md)

[6. Секционированные таблицы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-секционированными-таблицами)

[7. Индексы](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-индексами)

[8. Последовательности](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-последовательностями)

[9. Функции](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-функциями)

[10. Триггеры](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/readme.md#Работа-с-триггерами)



#### Работа с таблицами
##### Создание таблицы
            CREATE TABLE
Примеры:
##### Изменение свойств таблицы
            ALTER TABLE <name_table> SET SCHEMA <name_schema> ; - перемещение данных не происходит, изменения происходит в системном каталоге
            ALTER TABLE <name_table> SET tablespace <name_ts>; - Происходит физическое перемещение данных. Это требует иксклюзивной блокировки таблицы

##### Удаление таблицы
            DROP TABLE
               
##### Временные таблицы

1. Временные таблицы автоматически удаляются в конце сеанса или могут удаляться в конце текущей транзакции

2. Временные таблицы создаются в специальной схеме, так что при создании таких таблиц имя схемы задать нельзя

3. Для временных таблиц можно задать параметр ON COMMIT
 
Возможные значения:
     
  PRESERVE ROWS - никакие действия по завершении транзакции не выполняются (по умолчанию)
        
  DELETE ROWS   - при фиксации или отмене транзакции таблица очищается
        
  DROP          - при фиксации или отмене транзакции таблица удаляется 
  
  
#### Работа с секционированными таблицами

#### Работа с индексами

#### Работа с последовательностями

#### Работа с функциями

    \df - вывод списка доступных функций, которые есть в кластере Postgres


#### Работа с триггерами

    select tgname from pg_trigger; - вывод списка доступных триггеров в кластере Postgres

