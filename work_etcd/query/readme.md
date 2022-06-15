### Команды для для работы с кластером etcd

#### Вывод состояния клатера etcd

вывод списка членов кластера с детализацией 

    etcdctl -w json member list | jq   

вывод списка членов кластера с детализацией в виде таблицы (дополнительно выводит  PEER ADDRS)

    etcdctl -w table member list                               
    etcdctl --write-out=table --endpoints=localhost:2379 member list  
    
Вывод статуса кластера etcd:    

    ETCDCTL_API=3 /usr/local/bin/etcdctl endpoint status --cluster -w table
    /usr/local/bin/etcdctl endpoint status --cluster -w table
    
Надо разобратьс:
    
    /usr/local/bin/etcdctl --write-out=table --endpoints=$ENDPOINTS endpoint status
    
    etcdctl --endpoints=$ENDPOINTS endpoint health

диагностика всех конечных точек членов кластера 

    etcdctl endpoint --cluster health --user="root:root"                - 

Дефрагментация всех node кластера

    etcdctl defrag --cluster --user="root:root"     
