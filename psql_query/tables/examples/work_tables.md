### Примеры работы с таблицами

#### Примеры создания таблиц

    CREATE TABLE users (user_id SERIAL PRIMARY KEY NOT NULL, username varchar(50) NOT NULL,e-mail varchar(50) NOT NULL,city TEXT,record_date timestamp NOT NULL DEFAULT now()) ;
    
***Команда создания таблицы со следущими полями (особенности):***

user_id - PRIMERY KEY который является последовательность. Как последующее значение +1

record_date - дата и время создания записи timestamp NOT NULL DEFAULT now()
