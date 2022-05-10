#### Установка и настройка vip-manager 

Vip-manager управляет виртуальным IP-адресом на основе состояния, хранящегося в etcd или Consul. Отслеживает состояние в etcd.

Данное ПО можно использовать для переключения на Leader в отказоустойчивом кластере Patroni, если в данном кластере replices не используются в качестве node для выполнения запросов на чтение. 

vip-manager необходимо развернуть на каждой node которая включена в кластер Patroni.

Принцип работы: служба vip-manager на каждой node периодически обращается к кластеру etcd и определяет какая node является leader. На данной node подымается virtual IP по которому подключаются клиенты к Postgresql.

https://github.com/cybertec-postgresql/vip-manager - стариница с описанием vip-manager

https://github.com/cybertec-postgresql/vip-manager/releases - можно скачать rpm или deb пакет для установки


После установки необходимо настроить конфигурационный файл.

Данный файл размещен по адресу - /etc/default/vip-manager.yml

[Пример vip-manager.yml](https://github.com/Aleksey-10081967/Postgresql-study/tree/main/vip-manager/vip-manager.yml)

##### Пояснения
Строка: 

##### trigger-key: "/service-pro-ent/cluster-ent13/leader"

Формируется из параметров которые можно взять из  patroni.yml. 

Параметры файла:

    namespace: service-pro-ent
    
    scope: cluster-ent13

Имеем -> /namespace/scope/leader

##### trigger-value: "redoc-pgs01"  -> указал имя node кластера Patroni

##### ip: 192.168.122.201 -> virtual IP

Здесь указываются node кластера etcd:

##### dcs-endpoints:
        
        - http://192.168.122.165:2379
        
        - http://192.168.122.166:2379

Пользователь под которым подключаешься к etcd:

##### etcd-user:     "root"

##### etcd-password: "root"


