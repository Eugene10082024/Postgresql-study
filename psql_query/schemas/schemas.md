### Работа со схемами

[Что такое схема в Postgresql](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/psql_query/schemas/teor_schema.md)

Чтобы убрать права по умолчанию в схеме public (Первое слово «public» обозначает схему, а второе означает «каждый пользователь»
):

     REVOKE CREATE ON SCHEMA public FROM PUBLIC; 
     
