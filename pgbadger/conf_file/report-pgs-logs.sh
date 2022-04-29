#!/bin/bash
# переменная задающая кол-во дней за которые сохраняются отчеты
kol_days=$1

# Каталог размещения log postgresql
dir_postgresql_log=$2

#Каталог где размещаются отчеты
output_dir=$3

# Имя отчета, который будет сформирован за предыдующую дату 
output_file="othet"-`date +%d%m%Y -d "yesterday"`".html"


array_days=("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")

num_day_week=`date "+%u"`
if [[ "$num_day_week" -eq 1 ]]; then
	num_day_week=1
else
 	let num_day_week=$num_day_week-1
fi

#Имя log файла postgresql который будет использован для построения отчета за прошедший день
name_file_log="postgresql-"${array_days[($num_day_week-1)]}".log"

# Удаление отчетов созданных старше kol_days дней
find $output_dir -type f -mtime +$kol_days -exec rm -f {} \;


# Формирование отчета за предыдущий день 
/usr/bin/pgbadger -q -a 1  $dir_postgresql_log/$name_file_log -o $output_dir/$output_file


