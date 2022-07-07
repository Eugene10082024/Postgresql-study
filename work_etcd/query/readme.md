### Команды для проверки работы кластера etcd

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

##### диагностика всех конечных точек членов кластера 

    etcdctl endpoint --cluster health --user="root:root"       
    
Пример вывода:    

    root@astra-etcd01:~# etcdctl endpoint --cluster health --user="root:root"
    http://192.168.110.165:2379 is healthy: successfully committed proposal: took = 1.22653ms
    http://192.168.110.167:2379 is healthy: successfully committed proposal: took = 1.910143ms
    http://192.168.110.166:2379 is healthy: successfully committed proposal: took = 1.752447ms

#####  Дефрагментация всех node кластера

    etcdctl defrag --cluster --user="root:root"     





Надо разобратьс:
    
    /usr/local/bin/etcdctl --write-out=table --endpoints=$ENDPOINTS endpoint status
    
    etcdctl --endpoints=$ENDPOINTS endpoint health



  
