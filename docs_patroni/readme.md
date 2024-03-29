### Описание работы Patroni

[Создание кластера Patroni](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/docs_patroni/readme.md#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0-patroni)

[Как работает кластер Patroni](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/docs_patroni/readme.md#%D0%BA%D0%B0%D0%BA-%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0%D0%B5%D1%82-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80-patroni)

[Отработка autofailover](https://github.com/Aleksey-10081967/Postgresql-study/tree/main/docs_patroni#%D0%BE%D1%82%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0-autofailover)

[Отработка SPLIT-BRAIN](https://github.com/Aleksey-10081967/Postgresql-study/tree/main/docs_patroni#%D0%BE%D1%82%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0-split-brain)

[Каталоги и файлы Patroni (ver.2.1.4) при установке Patroni из под пользователя root](https://github.com/Aleksey-10081967/Postgresql-study/tree/main/docs_patroni#%D0%BA%D0%B0%D1%82%D0%B0%D0%BB%D0%BE%D0%B3%D0%B8-%D0%B8-%D1%84%D0%B0%D0%B9%D0%BB%D1%8B-patroni-ver214-%D0%BF%D1%80%D0%B8-%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B5-patroni-%D0%B8%D0%B7-%D0%BF%D0%BE%D0%B4-%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8F-root)

[Каталоги и файлы Patroni (ver.2.1.4) при установке Patroni из под пользователя postgres](https://github.com/Aleksey-10081967/Postgresql-study/tree/main/docs_patroni#%D0%BA%D0%B0%D1%82%D0%B0%D0%BB%D0%BE%D0%B3%D0%B8-%D0%B8-%D1%84%D0%B0%D0%B9%D0%BB%D1%8B-patroni-ver214-%D0%BF%D1%80%D0%B8-%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B5-patroni-%D0%B8%D0%B7-%D0%BF%D0%BE%D0%B4-%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8F-postgres)

#### Создание кластера Patroni

1. Запускаем сервис patroni на первом узле.

    1.1. Первый узел Patroni увидел, что кластера у нас еще нет. 
    
    1.2. Инициализировал мастер-узел, он запустил initdb. Initdb отработал. Он показал, что мы инициализировали новый кластер. 
    
    1.3. У узла, на котором мы это запустили, есть lock, т. е. у него есть индикация, что он лидер. И он об этом говорит: «lock owner: postgresql0; I om postgresql0», т. е. говорит, что все хорошо, он работает как мастер. 

2. Запускаем сервис patroni на втором узле.

    2.1. Второй узел нашел etcd-сервер. 
    
    2.2. Нашел, что кластер уже создан. У него уже есть лидер. И в etcd уже есть информация про то, что кластер создали. 
    
    2.3. Поэтому вместо того, чтобы запускать initdb и стать мастером, он запустил pg_basebackup. Это утилита Postgres, которая позволяет вам создавать реплики. И создал себя в качестве реплики. 
    
    2.4. После этого попытался стартовать Postgres. Он ждет пока Postgres стартует. Это может занять некоторое время. После чего он сказал, что он не может получить WAL-файлы. Он сказал, что не может получить файлы с мастера.
    
Почему так?

Он сказал, что не может включить репликацию, потому что Patroni еще не создал слот. На мастере Patroni смотрит на список реплик, которые подключились. И для каждой реплики создает слот через некоторое время. 
         
Немного ждем. Ошибки прикращаются.
 
#### Как работает кластер Patroni.

1. Master узел (leader) периодически отправляет запрос в etcd на обновление ключа кластера. ( По умолчанию 1 раз в 30 сек).
У каждого leader есть ttl (время в секундах, по истечению которго ключ пропадает).

            Запрос от Leader -> UPDATE("/leader","A",ttl=30,prevValue="A")
    
2. Если что-то случилось с Master узлом (leader) и ключ лидера не обновляется и через некоторое время ключ протухнет.

3. Остальные узлы (Replicas) получают оповещение от etcd, что лидера нет

            Оповещение от etcd -> Notify(/leader, expired=true)

4. Оставшиеся узлы проводят выборы.

    4.1. Каждый узел обращается ко всем другим узлам, включая старый исчезнувший мастер. Потому что вдруг это были какие-то временные проблемы, и вдруг он до сих пор жив. В этом надо убедиться.

    4.2. Каждый узел сравнивает позицию WAL со своей. При условии, если нода является впереди всех остальных или хотя бы не отстает. И те которые врепеди всех начинают гонку за лидером, отправляя запрос на создание нового ключа лидера в etcd.
    
            Запрос на создание ключа -> CREATE("/leader","B",ttl=30,prevExists=False)
    
etcd позволяет такие вещи делать атомарно. Т. е. когда одна нода создала ключ, то вторая нода, при условии, что мы запрещаем перезаписывать уже существующий ключ, его создать не сможет.

   4.3. Один из узлов получает ключ leader и становиться Master.Она выполняет promote для Postgres. Остальные становятся replica которые будут реплицировать данные с другого Master (leader).

#### Отработка autofailover

При падении Master узла c репликой некоторое время ничего не происходит. Потому что пока еще у Patroni есть режим лидера. Пока еще в etcd находится ключ лидера. Должно пройти некоторое время. В данном случае при дефолтной конфигурации – это до 30 секунд. Это контролируется специальным параметром «ttl». 

Дальше случился вот такой warning в логах -> WARNING: request failed: GET http://127.0.0.1:8008/patroni

Patroni сказал «request failed», т. е. не получилось сделать GET request. 

Что это такое? Patroni увидел, что lock’a в etcd больше нет. И попытался постучаться на мастер. Когда lock теряется, Patroni стучится на все известные узлы в кластере. 

И спрашивает у этого узла: «Ты – мастер?». А если он не мастер, то Patroni спрашивает позицию wal’а, т. е. насколько этот узел ближе к мастеру.

Patroni попытался спросить у мастера: «Доступен ли ты?». И мастер ему ничего не ответил, потому что упал
. 
И после того, как это случилось, он принял решение сделать себе promotion, т. е. стать после этого лидером. 

Patroni порядка две секунды тратит для каждой ноды, чтобы получить оттуда ответ. Все ноды он опрашивает параллельно.Некоторое время он ждет, пока не ответит мастер. После этого делает себе promotion. Node которая сделала себе promotion становится leader.

#### Отработка SPLIT-BRAIN

На одной из узлов мы запускаем Patroni.

Внезапно Patroni увидел, что он – мастер и то, что уже существует мастер. 

И что делает Patroni?

Patroni сделал demoting Postgres настолько быстро, насколько возможно. Т. е. он сказал Postgres – сделай immediate shutdown прямо сейчас без всяких прелюдий.  
Postgres сделал immediate shutdown. 
Это полупанический shutdown, т. е. он просто убивает все процессы, которые у вас есть. 

Patroni остановил базу данных и потом он сказал, что сделаю demoting, т. е. действие обратное promotion, потому что у меня нет lock’а. И после этого он стартовал Postgres.

Он делал crash recovery, потому что immediate shutdown – это не является чистой остановкой базы. И он препятствует pg_rewind.

Pg_rewind откажется работать с кластером, у которого не было чистой остановки. 

Поэтому Patroni запускает crash recovery mode в single user. Patroni просто запускает Postgresql в single user и останавливает. После этого запускает pg_rewind, потому что Patroni знает, что там старый мастер был немного впереди нового мастера, когда произошел promotion.

Т. е. мы запустились в crash recovery. Когда он запустился, он проверил свою позицию в wal-сегменте. И он проверил wal-сегмент мастера. И он нашел, что произошел split-brain, потому что он – реплика, но он ушел вперед от мастера. И он принял решение запустить pg_rewind.

Что такое pg_rewind? Это утилита в Postgres, которая позволяет предыдущему мастеру подключиться как реплика и перемотать обратно все те изменения, которые не попали на текущий мастер. Он перематывает до того момента, когда произошел разрыв между мастером и репликой, когда существующий мастер сделал promotion.

#### Каталоги и файлы Patroni (ver.2.1.4) при установке Patroni из под пользователя root
***/usr/local/bin или /usr/bin*** - каталог размещения бинарных файлов Patroni

Файлы размещенные в данном каталоге:

        -rwxr-xr-x 1 root root 219 May  5 18:53 patroni
        -rwxr-xr-x 1 root root 222 May  5 18:53 patroni_aws
        -rwxr-xr-x 1 root root 212 May  5 18:53 patronictl
        -rwxr-xr-x 1 root root 226 May  5 18:53 patroni_raft_controller
        -rwxr-xr-x 1 root root 231 May  5 18:53 patroni_wale_restore

***/usr/local/lib64/python3.6/site-packages/*** - каталог 64 bit библиотек используемых для работы Patroni 

Файлы размещенные в данном каталоге:

        drwxr-xr-x  4 root root  328 May  5 18:47 psutil
        drwxr-xr-x  2 root root  157 May  5 18:47 psutil-5.9.0-py3.6.egg-info
        drwxr-xr-x  3 root root  264 May  5 18:47 psycopg2
        drwxr-xr-x  2 root root  119 May  5 18:47 psycopg2_binary-2.9.3.dist-info
        drwxr-xr-x  2 root root 4096 May  5 18:47 psycopg2_binary.libs
        drwxr-xr-x  2 root root  102 May  5 18:47 PyYAML-6.0.dist-info
        drwxr-xr-x  3 root root 4096 May  5 18:47 yaml
        drwxr-xr-x  3 root root   44 May  5 18:47 _yaml
        
***/usr/local/lib/python3.6/site-packages/***  - каталог библиотек используемых для работы Patroni

Файлы размещенные в данном каталоге:

        drwxr-xr-x 31 root root   4096 May  5 17:29 .
        drwxr-xr-x  3 root root     27 May  5 17:23 ..
        drwxr-xr-x  3 root root   4096 May  5 17:29 click
        drwxr-xr-x  2 root root    106 May  5 17:29 click-8.0.4.dist-info
        drwxr-xr-x  6 root root    210 May  5 17:29 dateutil
        drwxr-xr-x  3 root root     63 May  5 17:29 _distutils_hack
        -rw-r--r--  1 root root    152 May  5 17:29 distutils-precedence.pth
        drwxr-xr-x  4 root root   4096 May  5 17:29 dns
        drwxr-xr-x  2 root root     81 May  5 17:29 dnspython-2.2.1.dist-info
        drwxr-xr-x  4 root root    104 May  5 17:29 etcd
        drwxr-xr-x  3 root root    195 May  5 17:29 importlib_metadata
        drwxr-xr-x  2 root root    102 May  5 17:29 importlib_metadata-4.8.3.dist-info
        drwxr-xr-x  7 root root   4096 May  5 17:29 patroni
        drwxr-xr-x  2 root root    155 May  5 17:29 patroni-2.1.3.dist-info
        drwxr-xr-x  5 root root    111 May  5 17:29 pip
        drwxr-xr-x  2 root root    130 May  5 17:29 pip-21.3.1.dist-info
        drwxr-xr-x  6 root root     86 May  5 17:29 pkg_resources
        drwxr-xr-x  3 root root     66 May  5 17:29 prettytable
        drwxr-xr-x  2 root root    102 May  5 17:29 prettytable-2.5.0.dist-info
        drwxr-xr-x  2 root root    127 May  6 14:26 __pycache__
        drwxr-xr-x  2 root root    118 May  5 17:29 python_dateutil-2.8.2.dist-info
        drwxr-xr-x  2 root root    157 May  5 17:29 python_etcd-0.4.5-py3.6.egg-info
        drwxr-xr-x  7 root root   4096 May  5 17:29 setuptools
        drwxr-xr-x  2 root root    126 May  5 17:29 setuptools-59.6.0.dist-info
        drwxr-xr-x  2 root root    102 May  5 17:29 six-1.16.0.dist-info
        -rw-r--r--  1 root root  34549 May  5 17:29 six.py
        drwxr-xr-x  2 root root     81 May  5 17:29 typing_extensions-4.1.1.dist-info
        -rw-r--r--  1 root root 107685 May  5 17:29 typing_extensions.py
        drwxr-xr-x  6 root root    291 May  5 17:29 urllib3
        drwxr-xr-x  2 root root    106 May  5 17:29 urllib3-1.26.9.dist-info
        drwxr-xr-x  4 root root    164 May  5 17:29 wcwidth
        drwxr-xr-x  2 root root    118 May  5 17:29 wcwidth-0.2.5.dist-info
        drwxr-xr-x  2 root root    117 May  5 17:29 ydiff-1.2-py3.6.egg-info
        -rw-r--r--  1 root root  34532 May  5 17:29 ydiff.py
        drwxr-xr-x  2 root root    102 May  5 17:29 zipp-3.6.0.dist-info
        -rw-r--r--  1 root root   8425 May  5 17:29 zipp.py

#### Каталоги и файлы Patroni (ver.2.1.4) при установке Patroni из под пользователя postgres

***~/.local/bin*** - каталог размещения бинарных файлов Patroni

Файлы размещенные в данном каталоге:

        drwxrwxr-x. 2 postgres postgres 167 июн 23 17:20 .
        drwx------. 5 postgres postgres  41 июн 23 17:18 ..
        -rwxrwxr-x. 1 postgres postgres 219 июн 23 17:18 patroni
        -rwxrwxr-x. 1 postgres postgres 222 июн 23 17:18 patroni_aws
        -rwxrwxr-x. 1 postgres postgres 212 июн 23 17:18 patronictl
        -rwxrwxr-x. 1 postgres postgres 226 июн 23 17:18 patroni_raft_controller
        -rwxrwxr-x. 1 postgres postgres 231 июн 23 17:18 patroni_wale_restore

***~/.local/lib/python3.6/site-packages*** - каталог библиотек используемых для работы Patroni

Файлы размещенные в данном каталоге:

        drwxrwxr-x.  3 postgres postgres   4096 июн 23 17:18 click
        drwxrwxr-x.  2 postgres postgres    106 июн 23 17:18 click-8.0.4.dist-info
        drwxrwxr-x.  6 postgres postgres    210 июн 23 17:18 dateutil
        drwxrwxr-x.  4 postgres postgres   4096 июн 23 17:18 dns
        drwxrwxr-x.  2 postgres postgres     81 июн 23 17:18 dnspython-2.2.1.dist-info
        drwxrwxr-x.  4 postgres postgres    104 июн 23 17:18 etcd
        drwxrwxr-x.  3 postgres postgres    195 июн 23 17:18 importlib_metadata
        drwxrwxr-x.  2 postgres postgres    102 июн 23 17:18 importlib_metadata-4.8.3.dist-info
        drwxrwxr-x.  7 postgres postgres   4096 июн 23 17:18 patroni
        drwxrwxr-x.  2 postgres postgres    155 июн 23 17:18 patroni-2.1.4.dist-info
        drwxrwxr-x.  5 postgres postgres    111 июн 23 17:20 pip
        drwxrwxr-x.  2 postgres postgres    130 июн 23 17:20 pip-21.3.1.dist-info
        drwxrwxr-x.  3 postgres postgres     66 июн 23 17:18 prettytable
        drwxrwxr-x.  2 postgres postgres    102 июн 23 17:18 prettytable-2.5.0.dist-info
        drwxrwxr-x.  4 postgres postgres   4096 июн 23 17:18 psutil
        drwxrwxr-x.  2 postgres postgres    157 июн 23 17:18 psutil-5.9.1-py3.6.egg-info
        drwxrwxr-x.  3 postgres postgres    264 июн 23 17:23 psycopg2
        drwxrwxr-x.  2 postgres postgres    119 июн 23 17:23 psycopg2_binary-2.9.3.dist-info
        drwxrwxr-x.  2 postgres postgres   4096 июн 23 17:23 psycopg2_binary.libs
        drwxrwxr-x.  2 postgres postgres    127 июн 23 17:18 __pycache__
        drwxrwxr-x.  2 postgres postgres    118 июн 23 17:18 python_dateutil-2.8.2.dist-info
        drwxrwxr-x.  2 postgres postgres    157 июн 23 17:18 python_etcd-0.4.5-py3.6.egg-info
        drwxrwxr-x.  2 postgres postgres    102 июн 23 17:18 PyYAML-6.0.dist-info
        drwxrwxr-x.  2 postgres postgres    102 июн 23 17:18 six-1.16.0.dist-info
        -rw-rw-r--.  1 postgres postgres  34549 июн 23 17:18 six.py
        drwxrwxr-x.  2 postgres postgres     81 июн 23 17:18 typing_extensions-4.1.1.dist-info
        -rw-rw-r--.  1 postgres postgres 107685 июн 23 17:18 typing_extensions.py
        drwxrwxr-x.  6 postgres postgres   4096 июн 23 17:18 urllib3
        drwxrwxr-x.  2 postgres postgres    106 июн 23 17:18 urllib3-1.26.9.dist-info
        drwxrwxr-x.  4 postgres postgres    164 июн 23 17:18 wcwidth
        drwxrwxr-x.  2 postgres postgres    118 июн 23 17:18 wcwidth-0.2.5.dist-info
        drwxrwxr-x.  3 postgres postgres   4096 июн 23 17:18 yaml
        drwxrwxr-x.  3 postgres postgres     44 июн 23 17:18 _yaml
        drwxrwxr-x.  2 postgres postgres    117 июн 23 17:18 ydiff-1.2-py3.6.egg-info
        -rw-rw-r--.  1 postgres postgres  34532 авг  8  2020 ydiff.py
        drwxrwxr-x.  2 postgres postgres    102 июн 23 17:18 zipp-3.6.0.dist-info
        -rw-rw-r--.  1 postgres postgres   8425 июн 23 17:18 zipp.py

Пакеты необходимые для Patroni.

        [root@vdc01-piupddbn1 bin]# python3.6 -m pip list
         Package            Version
         ------------------ -------
         click              8.0.4
         dnspython          2.2.1
         importlib-metadata 4.8.3
         patroni            2.1.3
         pip                21.3.1
         prettytable        2.5.0
         psutil             5.9.0
         psycopg2-binary    2.9.3
         python-dateutil    2.8.2
         python-etcd        0.4.5
         PyYAML             6.0
         setuptools         59.6.0
         six                1.16.0
         typing_extensions  4.1.1
         urllib3            1.26.9
         wcwidth            0.2.5
         ydiff              1.2
         zipp               3.6.0
