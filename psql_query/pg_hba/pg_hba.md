### Работа с pg_hba.conf

#### Проверка правильности запонения pg_hba.conf

Версия от 10 и выше:

        SELECT * FROM  pg_hba_file_rules;
        
Версия до 9.6:

        SELECT pg_read_file('pg_hba.conf');
