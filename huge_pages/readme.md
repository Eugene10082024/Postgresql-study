### Настройка HugePages в Postgresql

Статьи:

https://docs.oracle.com/database/121/UNXAR/appi_vlm.htm#UNXAR391 - HugePages
    
https://habr.com/ru/post/228793/ - Huge Pages в PostgreSQL
    
https://habr.com/ru/company/southbridge/blog/435558/ - Тестирование PostgreSQL с HugePages в Linux (основная рекомендация — отключать Transparent HugePages)
    

##### Пример настройки HugePage показал для следующих параметров памяти:

            Memory OC - 64 GB
            shared_buffers = 48GB

##### Для начала провередения работ обязательно проверяем можел ли ядро использовать HugePages.

1. Проверяем может ли ядро использовать HugePage

        [root@redoc-7 ~]# grep Huge /proc/meminfo
                AnonHugePages:          0 kB
                ShmemHugePages:         0 kB
                FileHugePages:          0 kB
                HugePages_Total:        0
                HugePages_Free:         0
                HugePages_Rsvd:         0
                HugePages_Surp:         0
                Hugepagesize:       2048 kB
                Hugetlb:                0 kB

Если в выводе указан Hugepagesize то ядро скомпелировано с параметрами позволяющими использовать HugePage 
Если нет необходимо перекомпилировать ядро с соответвествующими параметрами.    

#### Отключаем Transparent HugePages.

1. Проверяем текущий статус Transparent HugePages

        cat /sys/kernel/mm/transparent_hugepage/enabled
        [always] madvise never - Transparent HugePages включены
    
То что в скобках, то и действует

always означает, что transparent hugepages включены всегда и для всех процессов.Обычно это повышает производительность, но если у вас есть вариант использования, где множество процессов потребляет небольшое количество памяти, то общая нагрузка на память может резко возрасти.

madvise означает, что transparent hugepages включены только для областей памяти, которые явно запрашивают hugepages с помощью madvise(2)

never означает, что transparent hugepages не будут включаться даже при запросе с помощью madvise. 


2. Редактируем  config grub

         vi /etc/default/grub

Находим строку  GRUB_CMDLINE_LINUX и добавляем "transparent_hugepage=never" в конец строки.

         GRUB_CMDLINE_LINUX="resume=/dev/mapper/cl-swap rd.lvm.lv=cl/root rd.lvm.lv=cl/swap rhgb quiet transparent_hugepage=never"

3. Generate new GRUB boot menu based on customized configuration file.

         grub2-mkconfig -o /boot/grub2/grub.cfg
    
4. Restart Linux operating system to apply new settings.

        reboot now

5. После перезагрузки проверяем статус Transparent HugePages

         cat /sys/kernel/mm/transparent_hugepage/enabled
         always madvise [never]
    
#### Дополнительная настройка OC (Рекомендация Oracle)

1. Проверяем может ли ядро использовать HugePage

        [root@redoc-7 ~]# grep Huge /proc/meminfo
                AnonHugePages:          0 kB
                ShmemHugePages:         0 kB
                FileHugePages:          0 kB
                HugePages_Total:        0
                HugePages_Free:         0
                HugePages_Rsvd:         0
                HugePages_Surp:         0
                Hugepagesize:       2048 kB
                Hugetlb:                0 kB

Если в выводе указан Hugepagesize то ядро скомпелировано с параметрами позволяющими использовать HugePage 

2. Отредактировать параметры memlock в файле /etc/security/limits.conf.

Значения memlock указываются в KB. 

Максимальный предел заблокированной памяти (locked memory) должен быть установлен как минимум на 90 процентов от текущего объема ОЗУ.
 
 Для нашего примера (ОЗУ - 64GB):
 
            *   soft   memlock    60397977
            *   hard   memlock    60397977

Обязательно memlock должен быть больше shared_buffers.

3. Подключаемся под пользователем postgres и проверяем:
             $ ulimit -l
                60397977

#### Включение HugePages в ОС.

1. Запускаем PostgresPro с установленным размером  shared_buffers (Пример shared_buffers = 48GB)
 
            systemctl start postgrespro-ent-13.service 
    
2. Опеределаем размер HugePage который мы может использовать в OC (можно из под root, можно из под postgresql):

            grep Hugepagesize /proc/meminfo
            Hugepagesize:       2048 kB


3. Определяем pid процесса postgrespro (выполняем под root):
 
            head -1 /pgstore/pgdata/postmaster.pid 
            Для примера
                769
        
4.  Определяем пиковое значение использования виртуальной памяти (VmPeak) используемое PostgresPro

            grep ^VmPeak /proc/769/status
            Для примера:
                VmPeak: 51867736 kB

5. Выполняем расчет кол-ва HugePage 

        kol_hugepage=(VmPeak/Hugepagesize +1)
    
        Для примера
            echo $((51866736 / 2048 + 1))
            25326
    
6. 
        echo 'vm.nr_hugepages = 25326' >> /etc/sysctl.d/30-postgresql.conf

7. 
        sysctl -p --system

8. Останавливаем PostgresPro

        systemctl stop postgrespro-ent-13.service
        
9. Редактируем файл postgresql.conf меняя параметр huge_pages = try

        huge_pages = on
    
10. Запускаем PostgresqlPro

        systemctl start postgrespro-ent-13.service 
    
11. Смотрим использование HugePages
    
        grep ^HugePages /proc/meminfo
            HugePages_Total:   25326
            HugePages_Free:    24790
            HugePages_Rsvd:    24635
            HugePages_Surp:        0
      