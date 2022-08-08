### Утилита pgbadger для формирования отчетов на основе logs postgresql

pgbadger - PostgreSQL log analyzer предназначенный для детального постороения отчетов и графиков.

Ссылка на github.com - https://github.com/darold/pgbadger.

В данных материалах сама установка не рассматривается. Есть раздел о установке данной утилиты из исходных кодов на github. Также ее можно установить и соответствующих пакетов репозиториев Postgresql и PostgresPro

#### Настройка pgbadger

#### 1. Установка конфигурационных параметров в файле postgresql.conf

Для правильной работы утилиты необходимо задать следующие параметры в postgresql.conf.

      log_filename = 'postgresql-%a.log'
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
      
##### ВНИМАНИЕ
log_filename - параметр должен иметь именно такое значение. Для других значений имен файлов нужно переделывать скрипт report-pgs-logs.sh

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

2.3. Файл report-pgs-logs.service 
      [Unit]
      Description=generating a report for the previous day
      Wants=perort_psql.timer

      [Service]
      Type=oneshot
      User=postgres
      Group=postgres
      EnvironmentFile=/etc/default/report-pgs-logs.cfg
      ExecStart=/usr/bin/report-pgs-logs.sh $DAYS $DIR_LOG_PGS $DIR_OUTPUT
      ExecReload=/bin/kill -HUP $MAINPID
      KillMode=process

      [Install]
      WantedBy=multi-user.target
      
2.4. Файл report-pgs-logs.timer

      [Unit]
      Description=timer start demon report-pgs-logs.service
      [Timer]
      OnCalendar=Tue..Sat *-*-* 02:00:00
      Unit=report-pgs-logs.service
      [Install]
      WantedBy=timers.target

В данном файле указано что отчет будет создаваться во "Вторник, Среда, Четверг, Пятница, Суббота" в 2 часа ночи

2.5. Файл report-pgs-logs.sh

            #!/bin/bash
            # переменная задающая кол-во дней за которые сохраняются отчеты
            kol_days=$1
            # Каталог размещения log postgresql
            dir_postgresql_log=$2
            #Каталог где размещаются отчеты
            output_dir=$3
            date_yesterday=`date +%Y-%m-%d -d "yesterday"`
            # Имя отчета, который будет сформирован за предыдующую дату 
            output_file="report-"$date_yesterday".html"
            array_days=("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")
            num_day_week=`date "+%u"`
            if [[ "$num_day_week" -eq 1 ]]; then
                  num_day_week=7
            else
                  let num_day_week=$num_day_week-1
            fi
            #Имя log файла postgresql который будет использован для построения отчета за прошедший день
            # Номер элемента массива начинается с 0, поэтому $num_day_week-1
            name_file_log="postgresql-"${array_days[($num_day_week-1)]}".log"
            # Удаление отчетов созданных старше kol_days дней
            find $output_dir -type f -mtime +$kol_days -exec rm -f {} \;
            # Формирование отчета за предыдущий день
            /usr/bin/pgbadger $dir_postgresql_log/$name_file_log -o $output_dir/$output_file -b $date_yesterday" 00:00:01" -e $date_yesterday" 23:59:59"

#### 3. Выполнение настройки для ежедневного формирования отчетов через systemd
 3.1. Перечисленные выше файлы копируются в один каталог.
 
 3.2. Выполняется предоставление права на исполнение файла install_service.sh
 
    chmod -755 install_service.sh
    
 3.3. Выполняется скрипт  install_service.sh 
 
    ./install_service.sh 
   
 
 
 
      
