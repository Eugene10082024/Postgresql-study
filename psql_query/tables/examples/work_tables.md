### Примеры работы с таблицами

#### Примеры создания таблиц

##### Пример 1

    CREATE TABLE users (user_id SERIAL PRIMARY KEY NOT NULL, 
                        username varchar(50) NOT NULL,
                        e-mail varchar(50) NOT NULL,city TEXT,
                        record_date timestamp NOT NULL DEFAULT now()) ;
    
***Команда создания таблицы со следущими полями (особенности):***

user_id - PRIMERY KEY который является последовательность. Как последующее значение +1

record_date - дата и время создания записи timestamp NOT NULL DEFAULT now()

##### Пример 2 - Создание 2 таблиц со связанной таблицей

         CREATE TABLE users(
                    user_id SERIAL PRIMARY KEY NOT NULL,             -- Primary Key
                    username varchar(50) NOT NULL,                   -- Имя пользователя
                    email varchar(50) NOT NULL,                      -- Электронная почта
                    mobile_phone varchar(12) NOT NULL,               -- Номер телефона
                    firstname TEXT NOT NULL,                         -- Имя
                    lastname TEXT NOT NULL,                          -- Фамилия
                    city  TEXT,                                      -- Название города
                    is_curator boolean NOT NULL,                     -- Является ли пользователь куратором
                    record_date timestamp NOT NULL DEFAULT now()     -- Время создания записи о пользователе
                    );

                CREATE TABLE courses(
                    course_id SERIAL PRIMARY KEY NOT NULL,  -- Primary Key
                    coursename varchar(50) NOT NULL,        -- Название практикума
                    tasks_count INT NOT NULL,               -- Количество заданий в практикуме
                    price INT NOT NULL                      -- Цена практикума
                    );


                CREATE TABLE users__courses(
                    id SERIAL PRIMARY KEY NOT NULL,     -- Primary Key
                    user_id INT NOT NULL,               -- Foreign Key to table users
                    course_id INT NOT NULL,             -- Foreign Key to table courses
                    CONSTRAINT fk_user_id
                        FOREIGN KEY (user_id)
                            REFERENCES users(user_id),
                    CONSTRAINT fk_course_id
                        FOREIGN KEY (course_id)
                            REFERENCES courses(course_id)
                    );

INSERT

        INSERT INTO users (username,email,mobile_phone,firstname,lastname,city,is_curator) VALUES ('admin','vasiliy_ozerov@mail.com','+79111937483','Vasiliy','Ozerov','Moscow','true')
        INSERT INTO courses (coursename,tasks_count,price) VALUES ('Kubernetes','70','35000'),('Highload','130','75000'),('Bash','15','6900')

UPDATE

        UPDATE courses SET coursename = 'LINUX-UBUNTU" WHERE coursename = 'LINUX';
        UPDATE courses SET price = 100000 where coursename='Devops';

DELETE

        DELETE FROM users WHERE username='admin';

##### Пример 3. Создание таблицы для тестов.

        CREATE TABLE  my_table (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, info text, date timestamp);
        CREATE TABLE
        
        INSERT INTO my_table (info,date) VALUEs ('Первая запись',NOW());
        INSERT 0 1
        
        SELECT * FROM my_table;

