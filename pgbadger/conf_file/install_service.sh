#!/bin/bash

cp report-pgs-logs.sh /usr/bin/
chmod 755 /usr/bin/report-pgs-logs.sh

cp report-pgs-logs.service /etc/systemd/system/
cp report-pgs-logs.timer /etc/systemd/system/
cp report-pgs-logs.cfg   /etc/default/

# Создание папки для размещения отчетов
# Местонахождение и название папки должно полностью совпадать со значением переменной DIR_OUTPUT фаала  report-pgs-logs.cfg
mkdir -p /home/postgres/reports/pgbadger

# Назначение  владельцем postgres созданной папки. Неоходимо т.к.  report-pgs-logs.service выполняется под postgres
chown -R postgres:postgres /home/postgres/reports/pgbadger

systemctl daemon-reload
systemctl enable report-pgs-logs.timer
systemctl enable report-pgs-logs.service
systemctl start report-pgs-logs.timer
systemctl start report-pgs-logs.service
