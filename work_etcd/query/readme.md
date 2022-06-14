### Команды для для работы с кластером etcd

#### Вывод состояния клатера etcd

вывод списка членов кластера с детализацией

    etcdctl -w json member list | jq   

вывод списка членов кластера с детализацией в виде таблицы

    etcdctl -w table member list                                     
    etcdctl --write-out=table --endpoints=localhost:2379 member list  

диагностика всех конечных точек членов кластера 

    etcdctl endpoint --cluster health --user="root:root"                - 

Дефрагментация всех node кластера

    etcdctl defrag --cluster --user="root:root"     
