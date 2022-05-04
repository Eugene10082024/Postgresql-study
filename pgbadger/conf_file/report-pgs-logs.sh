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
