### Команды для работы с кластером etcd

[1. Вывод состояния кластера](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/work_etcd/query/readme.md#%D0%B2%D1%8B%D0%B2%D0%BE%D0%B4-%D1%81%D0%BE%D1%81%D1%82%D0%BE%D1%8F%D0%BD%D0%B8%D1%8F-%D0%BA%D0%BB%D0%B0%D1%82%D0%B5%D1%80%D0%B0-etcd)

[2. Дефрагментация всех узлов кластера](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/work_etcd/query/readme.md#%D0%B4%D0%B5%D1%84%D1%80%D0%B0%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0%D1%86%D0%B8%D1%8F-%D0%B2%D1%81%D0%B5%D1%85-%D1%83%D0%B7%D0%BB%D0%BE%D0%B2-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0)

[3. Проведение ручной дефрагментации узла etcd](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/work_etcd/query/readme.md#%D0%BF%D1%80%D0%BE%D0%B2%D0%B5%D0%B4%D0%B5%D0%BD%D0%B8%D0%B5-%D1%80%D1%83%D1%87%D0%BD%D0%BE%D0%B9-%D0%B4%D0%B5%D1%84%D1%80%D0%B0%D0%B3%D0%BC%D0%B5%D0%BD%D1%82%D0%B0%D1%86%D0%B8%D0%B8-%D1%83%D0%B7%D0%BB%D0%B0-etcd)

[4. Пересоздание узла кластера etcd](https://github.com/Aleksey-10081967/Postgresql-study/blob/main/work_etcd/query/readme.md#%D0%BF%D0%B5%D1%80%D0%B5%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D1%83%D0%B7%D0%BB%D0%B0-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0-etcd)


#### Вывод состояния клатера etcd

##### вывод списка членов кластера с детализацией 

    etcdctl -w json member list | jq   
    
 Пример вывода:
 
       root@astra-etcd01:~# etcdctl -w json member list | jq  
        {
          "header": {
            "cluster_id": 308897003961609500,
            "member_id": 8872342382697417000,
            "raft_term": 123
          },
          "members": [
            {
              "ID": 5619389476742426000,
              "name": "astra-etcd02",
              "peerURLs": [
                "http://192.168.110.166:2380"
              ],
              "clientURLs": [
                "http://192.168.110.166:2379"
              ]
            }
          ]
        }


##### вывод списка членов кластера с детализацией в виде таблицы (дополнительно выводит  PEER ADDRS)

    etcdctl -w table member list                               
    etcdctl --write-out=table --endpoints=localhost:2379 member list  

Пример вывода:

    root@astra-etcd01:~# etcdctl --write-out=table --endpoints=localhost:2379 member list
    
    +------------------+---------+--------------+-----------------------------+-----------------------------+------------+
    |        ID        | STATUS  |     NAME     |         PEER ADDRS          |        CLIENT ADDRS         | IS LEARNER |
    +------------------+---------+--------------+-----------------------------+-----------------------------+------------+
    | 4dfc14f4cfccea9d | started | astra-etcd02 | http://192.168.110.166:2380 | http://192.168.110.166:2379 |      false |
    | 5ad19e80ba693f24 | started | astra-etcd03 | http://192.168.110.167:2380 | http://192.168.110.167:2379 |      false |
    | 7b20e463ae528631 | started | astra-etcd01 | http://192.168.110.165:2380 | http://192.168.110.165:2379 |      false |
    +------------------+---------+--------------+-----------------------------+-----------------------------+------------+
    
    /usr/local/bin/etcdctl member list --endpoints=http://10.7.155.31:2379 --user="root:passw0rd"
    
##### Вывод статуса кластера etcd:    

    ETCDCTL_API=3 etcdctl endpoint status --cluster -w table
    etcdctl endpoint status --cluster -w table
    
Пример вывода:

    root@astra-etcd01:~# etcdctl endpoint status --cluster -w table
    +-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
    |          ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
    +-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
    | http://192.168.110.166:2379 | 4dfc14f4cfccea9d |   3.5.2 |   44 MB |     false |      false |       123 |    3228774 |            3228774 |        |
    | http://192.168.110.167:2379 | 5ad19e80ba693f24 |   3.5.2 |   44 MB |     false |      false |       123 |    3228774 |            3228774 |        |
    | http://192.168.110.165:2379 | 7b20e463ae528631 |   3.5.2 |   44 MB |      true |      false |       123 |    3228774 |            3228774 |        |
    +-----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

#### диагностика всех конечных точек членов кластера 

    etcdctl endpoint --cluster health --user="root:root"       
    
Пример вывода:    

    root@astra-etcd01:~# etcdctl endpoint --cluster health --user="root:root"
    http://192.168.110.165:2379 is healthy: successfully committed proposal: took = 1.22653ms
    http://192.168.110.167:2379 is healthy: successfully committed proposal: took = 1.910143ms
    http://192.168.110.166:2379 is healthy: successfully committed proposal: took = 1.752447ms

####  Дефрагментация всех узлов кластера

Дефрагментация вручную должна выполняться периодически, чтобы освободить место на диске после сжатия истории etcd и других событий, вызывающих фрагментацию диска.

Сжатие истории выполняется автоматически каждые пять минут и оставляет пробелы во внутренней базе данных. Это фрагментированное пространство доступно для использования etcd, но недоступно файловой системе хоста. Вы должны дефрагментировать etcd, чтобы сделать это пространство доступным для файловой системы хоста.

ВНИМАНИЕ:
Дефрагментация etcd является блокирующим действием. Элемент etcd не будет отвечать, пока дефрагментация не будет завершена. По этой причине подождите не менее одной минуты между действиями дефрагментации на каждом из модулей, чтобы кластер мог восстановиться.

***Лидер должен быть дефрагментирован последним***

    etcdctl defrag --cluster --user="root:root"     

#### Проведение ручной дефрагментации узла etcd

    etcdctl --command-timeout=30s --endpoints=https://localhost:2379 defrag
    
Если возникает ошибка тайм-аута, увеличивайте значение --command-timeout до тех пор, пока команда не завершится успешно.

#### Error NOSPACE

Если возникли ошибки NOSPACE (превышения квоты пространства), выполните очистку.

    etcdctl alarm list
    etcdctl alarm disarm

#### Пересоздание узла кластера etcd

Останавливаем сервис на etcd 

        systemctl stop etcd

Определяем ID члена кластера etcd который надо удалить:

        etcdctl --write-out=table --endpoints=localhost:2379 member list       
        
        +------------------+-----------+--------------+-----------------------------+-----------------------------+------------+
        |        ID        |  STATUS   |     NAME     |         PEER ADDRS          |        CLIENT ADDRS         | IS LEARNER |
        +------------------+-----------+--------------+-----------------------------+-----------------------------+------------+
        | 4f0f239830682d9c |   started | astra-etcd03 | http://192.168.110.167:2380 | http://192.168.122.167:2379 |      false |
        | 5641e28dba68dda9 | unstarted |              | http://192.168.110.165:2380 |                             |      false |
        | 8b9292b8d107ea3a |   started | astra-etcd02 | http://192.168.110.166:2380 | http://192.168.122.166:2379 |      false |
        +------------------+-----------+--------------+-----------------------------+-----------------------------+------------+
        
Удаляем из кластра не работающего члена кластера:

        root@astra-etcd02:~# etcdctl member remove 5641e28dba68dda9 --user="root"
        Password: 
        Member 5641e28dba68dda9 removed from cluster 78dce426f7c2678a
        
Создаем члена кластера в кластере etcd:

        root@astra-etcd02:~# etcdctl member add astra-etcd01 --peer-urls=http://192.168.110.165:2380 --user="root:root"
        Member ec11318c7914e98f added to cluster 78dce426f7c2678a

        ETCD_NAME="astra-etcd01"
        ETCD_INITIAL_CLUSTER="astra-etcd03=http://192.168.110.167:2380,astra-etcd02=http://192.168.110.166:2380,astra-etcd01=http://192.168.110.165:2380"
        ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.110.165:2380"
        ETCD_INITIAL_CLUSTER_STATE="existing"

Удаляем БД etcd на сервере где была сломанная node etcd:

        rm -rf /var/lib/etcd/member
        
Запускаем сервис etcd на node:

        systemctl start etcd
