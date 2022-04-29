#!/bin/bash
cp report-pgs-logs.sh /usr/bin/
chmod 755 /usr/bin/report_psql.sh

cp report-pgs-logs.service /etc/systemd/system/
cp report-pgs-logs.timer /etc/systemd/system/
cp report-pgs-logs.cfg   /etc/default/

systemctl daemon-reload
systemctl start report-pgs-logs.timer
systemctl start report-pgs-logs.service
#systemctl enable report_psql.timer
#systemctl enable report_psql.service


