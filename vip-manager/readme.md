#### Установка и настройка vip-manager 

Vip-manager управляет виртуальным IP-адресом на основе состояния, хранящегося в etcd или Consul. Отслеживает состояние в etcd.

Данное ПО можно использовать для переключения на Leader в отказоустойчивом кластере Patroni, если в данном кластере replices не используются в качестве node для выполнения запросов на чтение.

https://github.com/cybertec-postgresql/vip-manager - стариница с описанием vip-manager

https://github.com/cybertec-postgresql/vip-manager/releases - можно скачать rpm или deb пакет для установки

После установки необходимо настроить конфигурационный файл.

Данный файл размещен по адресу - /etc/default/vip-manager.yml

