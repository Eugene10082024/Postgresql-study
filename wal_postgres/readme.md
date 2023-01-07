### Работа с WAL файлами

Логически журнал можно представить в виде непрерывного потока записей. Каждая запись имеет номер, называемый LSN (Log Sequence Number). 
Это 64-разрядное число — смещение записи в байтах относительно начала журнала.

Текущую позицию показывает функция pg_current_wal_lsn:

    SELECT pg_current_wal_lsn();

Интересны не абсолютные числа, а их разница, которая показывает размер сгенерированных журнальных записей в байтах:

    SELECT '0/345C900'::pg_lsn - '0/34598D0'::pg_lsn AS bytes;

На файлы можно взглянуть не только в файловой системе, но и с помощью функции:

    SELECT * FROM pg_ls_waldir() ORDER BY name;

Процесс walwriter, занимающийся асинхронной записью журнала на диск. При синхронном режиме записью журнала занимается тот процесс, который выполняет фиксацию транзакции.


Определение текущего WAL файла

    select pg_walfile_name(pg_current_wal_lsn();
    
Утилита pg_waldump просто декодирует содержимое XLOG сегментов в человеко-понятный формат

    pg_waldump -f -р /wal_10 $(psql -qAtX -с "select pg_walfile_name(pg_current_wal_lsn())")
    
Это аналог команды tail -f только для журналов транзакций. Эта команда показывает хвост журнала транзакций, которые прямо сейчас происходит. 
Можно запустить эту команду, она найдет последний сегмент с самой последней записью журнала транзакций, подключится к нему и начнет показывать 
содержимое журнала транзакций. 

Архивирование WAL

        select 
        case when ( last_failed_time > last_archived_time ) then failed_count else 0 end as failed_count,
        cast( last_archived_time as varchar ) ||
            case
                when ( last_failed_time > last_archived_time ) then
                '<br>' || cast( last_failed_time as varchar ) 
            else '' end
        from
        pg_stat_archiver
