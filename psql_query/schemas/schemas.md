### Работа со схемами

[Что такое схема в Postgresql](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/schemas/teor_schema.md)

 #### Просмотр схем используемых в БД
 	
	\с <name_db>
	SELECT * FROM pg_namespace;
 	
 #### Создание схемы:
 
     	CREATE SCHEMA schema_name;
     
 #### Создание объекта в схеме:
 
	 CREATE TABLE myschema.mytable (
	 ...
	 );

#### Удаление пустой схемы
     
    	DROP SCHEMA schema_name;
   
#### Удаление схемы со всем содержимым:
     
    	DROP SCHEMA schema_name CASCADE;
    
#### Смена схемы у объекта:
  
   	ALTER TABLE <name_table> SET SCHEMA <new_schema>;
	
### Поиск объектов в кластере Postgresql

#### Просмотр текущего типа поиска.

	SHOW search_path;   	
   
#### Добавление в путь новую схему

	SET search_path TO myschema,public;
	
При добавлении необходимо указывать все схемы в которых должен быть выполнен поиск. Последовательность тоже играет роль.

В данном случае т.к. myschema — первый элемент в пути, новые объекты будут по умолчанию создаваться в этой схеме.

	SET search_path TO myschema;
	
В данном случае не сможем обращаться к схеме public, не написав полное имя объекта.

### Назначение привелегий

Чтобы убрать права по умолчанию в схеме public (Первое слово «public» обозначает схему, а второе означает «каждый пользователь»):

     	REVOKE CREATE ON SCHEMA public FROM PUBLIC; 

#### Ниже приведены команды на предоставление привелегий на уже существующие объекты в указанной схеме.

Пользователь будет подключен к базе данных и получит все права для работы с ней

	GRANT CONNECT ON DATABASE postgres TO postgres;
	
все команды, примененные к таблице, были доступны пользователю

	GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO postgres;
	GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
	GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
	GRANT ALL PRIVILEGES ON DATABASE postgres TO postgres;
	
Назначение привелений на создаваемые объекты:

	ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO postgres;	
	





