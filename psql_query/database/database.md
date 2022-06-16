#### Работа с базой данных

#### Создание базы данных
            CREATE DATABASE <name_db> - создает БД database01 владельцем которой является текущий пользователь.
            CREATE DATABASE <name_db> OWNER <user_name> - создание БД с указанием владельца
            CREATE DATABASE <name_db> TABLESPACE <name_ts> - При создании БД мы можем указать табличное пр-во по умолчанию.
            
ВНИМАНИЕ: TABLESPACE должна быть создана.  В таком случае все создаваемые объекты бд будут попадать в табличное пр-во по умолчанию. 

            
            CREATE DATABASE <name_db> LOCALE 'sv_SE.utf8' TEMPLATE template0; - Создание базы данных с другой локалью
            CREATE DATABASE <name_db> LOCALE 'sv_SE.iso885915' ENCODING LATIN9 TEMPLATE template0; - cоздание базы данных с другой локалью и другой кодировкой символов
            CREATE DATABASE <name_db> IS_TEMPLATE=true - создается БД ввиде шаблона, которая может быть клонирована в дальнейшем
            
#### Создание БД на основе другой БД (копирование стуктуры и данных)

            CREATE DATABASE <name_db> TEMPLATE <source_db>;
            
#### Создание БД как шаблона

            CREATE DATABASE <name_db> IS_TEMPLATE = true;

#### Изменение свойств базы данных

            ALTER DATABASE <name_db> REMANE TO new_name_db - смена названия базы данных
            ALTER DATABASE <name_db> OWNER TO new_owner - смена владельца базы данных
            ALTER DATABASE <name_db> SET TABLESPACE <new_ts> - установка нового табличного пространства по умолчанию базы данных

#### Ограничение доступа к БД

            ALTER DATABASE <name_db> CONNECTION LIMIT 0 - установка ограничения на подключение
            ALTER DATABASE <name_db> CONNECTION LIMIT -1 - снятие ограничений на подключения
            ALTER DATABASE <name_db> ALLOW_CONNECTIONS = false - запрещение подключения к БД 
             
#### Удаление базы данных
            DROP DATABASE <name_db>; - удаление БД
            DROP DATABASE <name_db> FORCE;


            
            
