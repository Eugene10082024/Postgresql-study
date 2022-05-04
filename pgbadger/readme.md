### Утилита pgbadger для формирования отчетов на основе logs postgresql

pgbadger - PostgreSQL log analyzer предназначенный для детального постороения отчетов и графиков.

Ссылка на github.com - https://github.com/darold/pgbadger.

В данных материалах сама установка не рассматривается. Есть раздел о установке данной утилиты из исходных кодов на github. Также ее можно установить и соответствующих пакетов репозиториев Postgresql и PostgresPro

#### Настройка pgbadger

##### 1. Установка конфигурационных параметров в файле postgresql.conf

Для правильной работы утилиты необходимо задать следующие параметры в postgresql.conf.

      log_min_duration_statement = 0
      log_line_prefix = '%t [%p]: ' 
      log_checkpoints = on
      log_connections = on
      log_disconnections = on
      log_lock_waits = on
      log_temp_files = 0
      log_autovacuum_min_duration = 0
      log_error_verbosity = default
      lc_messages='en_US.UTF-8'
      
Также можно:
      log_line_prefix = '%t [%p]: user=%u,db=%d,app=%a,client=%h '
      
 Не рекомендуется включать log_statement, так как его формат журнала не будет анализироваться pgBadger.
 
 После того как вы внесли изменения в файл postgresql.conf ныполните команду заставоляющую postgresql перечетать конфигурационный файл в psql.
    
      SELECT pg_reload_conf();
      
 #### 2. Описание файлов.
 
 В каталоге conf данного раздела размещены следующие файлы:
 
     install_service.sh - скрипт первоначального развертывания конфигурационных файлов. Данный файл выполняется из под root или с sudo
     report-pgs-logs.cfg - файл с переменными необходимыми для работы основного скрипта
     report-pgs-logs.service -  файл настройки сервиса формирования отчетности
     report-pgs-logs.sh - скрипт который формирует отчет за предыдущий день и log файла
     report-pgs-logs.timer - файл настройки таймера

2.1. Файл install_service.sh

        #!/bin/bash
        cp report-pgs-logs.sh /usr/bin/
        chmod 755 /usr/bin/report-pgs-logs.sh
        cp report-pgs-logs.service /etc/systemd/system/
        cp report-pgs-logs.timer /etc/systemd/system/
        cp report-pgs-logs.cfg   /etc/default/
        # Создание папки для размещения отчетов
        # Местонахождение и название папки должно полностью совпадать со значением переменной DIR_OUTPUT фаала  report-pgs-logs.cfg
        mkdir -p /tmp/report
        # Назначение  владельцем postgres созданной папки. Неоходимо т.к.  report-pgs-logs.service выполняется под postgres
        chown -R postgres:postgres /tmp/report
        systemctl daemon-reload
        systemctl enable report-pgs-logs.timer
        systemctl enable report-pgs-logs.service
        systemctl start report-pgs-logs.timer
        systemctl start report-pgs-logs.service

2.2. Файл report-pgs-logs.cfg
        
        DAYS=7
        DIR_LOG_PGS='/var/log/postgresql'
        DIR_OUTPUT='/tmp/report'

Где:

      DAYS - кол-во дней хранения отчетов в какталоге заданном в переменной DIR_OUTPUT
      DIR_LOG_PGS - каталог с log файлами
      DIR_OUTPUT - каталог в которой будут помещены отчеты








#### 2. Выполнение настройки для ежедневного формирования отчетов через systemd
 3.1. Перечисленные выше файлы копируются в один каталог.
 
 3.2. Выполняется предоставление права на исполнение файла install_service.sh
 
    chmod -755 install_service.sh
    
 3.3. Выполняется скрипт  install_service.sh 
 
    ./install_service.sh 
   
 
 
 
      
