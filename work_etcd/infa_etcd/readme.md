### Использование REST API для получения информации из кластера etcd

#### Получение информации по членам кластера etcd

     curl http://localhost:2379/v2/members | jq
     
или можно указать IP соответсвующей node:

     curl http://192.168.122.165:2379/v2/members | jq

#### получение инфы по ключам кластера Patroni

    curl http://localhost:2379/v2/keys?recursive=true | jq
    
или можно указать IP соответсвующей node:    
    
    curl http://192.168.122.165:2379/v2/keys/service-pro-ent/cluster-ent13?recursive=true | jq
    
#### получение статистики по лидеру

    curl http://localhost:2379/v2/stats/leader | jq
    
 или можно указать IP соответсвующей node:   
    
    curl http://192.168.122.167:2379/v2/stats/leader | jq

#### получение статистики по node etcd

    curl http://localhost:2379/v2/stats/self | jq
  
или можно указать IP соответсвующей node:
  
    curl http://192.168.122.166:2379/v2/stats/self | jq
    

#### получение информации по node (redoc-pgs01) кластера cluster-ent13 (Patroni)

    curl http://192.168.122.165:2379/v2/keys/service-pro-ent/cluster-ent13/members/redoc-pgs01 | jq - 
    
