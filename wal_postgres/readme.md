### Работа с WAL файлами

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
