### Команды для для работы с кластером etcd

#### Вывод состояния клатера etcd

вывод списка членов кластера с детализацией

    etcdctl -w json member list | jq   

вывод списка членов кластера с детализацией в виде таблицы

    etcdctl -w table member list                                     
    etcdctl --write-out=table --endpoints=localhost:2379 member list  
    
Вывод статуса node кластера:    
    ETCDCTL_API=3 /usr/local/bin/etcdctl endpoint status --cluster -w table
    /usr/local/bin/etcdctl endpoint status --cluster -w table

Пример вывода:  
+---------------------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|                  ENDPOINT                   |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+---------------------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://vdc01-piupddbn2.dc-prod.tn.corp:2379 | 1c2df8ae4ddf3b90 |   3.5.4 |   20 kB |     false |      false |        48 |   15560451 |           15560451 |        |
| http://vdc01-piupddbn3.dc-prod.tn.corp:2379 | c6430acb3ca15735 |   3.5.4 |   20 kB |     false |      false |        48 |   15560451 |           15560451 |        |
| http://vdc01-piupddbn1.dc-prod.tn.corp:2379 | ce4fa280b428dbc0 |   3.5.4 |   20 kB |      true |      false |        48 |   15560451 |           15560451 |        |
+---------------------------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+


диагностика всех конечных точек членов кластера 

    etcdctl endpoint --cluster health --user="root:root"                - 

Дефрагментация всех node кластера

    etcdctl defrag --cluster --user="root:root"     
