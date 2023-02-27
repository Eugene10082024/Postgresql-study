### Создание кластера etcd для работы с Patroni
Создание кластера etcd для работы с Patroni включаем в себя следующие этапы:

Этап 1. Развертывание etcd на узлах планируемого кластера

Этап 2. Создание кластера etcd

Этап 3. Настройка авторизации в etcd

В примере для развертывания и настройки кластера etcd будет использовано три узла:

    astra-etcd01 - 192.168.122.165
    astra-etcd02 - 192.168.122.166
    astra-etcd03 - 192.168.122.167

В качестве ОС используется Astra Linux SE 1.6. Для развертывания кластера etcd это не принципиально.

### Этап 1. Развертывание etcd на узлах планируемого кластера

ВНИМАНИЕ : Все описанные действия в данном пункте необходимо выполнить на каждом узле кластера.

1.1. Создание пользователя пользователя под которым будет работать etcd и необходимых каталогов с соответсвующим владельцем и правами.

    sudo groupadd --system etcd
    sudo useradd -s /sbin/nologin --system -g etcd etcd
    sudo mkdir -p /var/lib/etcd/
    sudo chown -R etcd:etcd /var/lib/etcd/
    sudo mkdir /etc/etcd
    sudo cp etcd /usr/local/bin/
    sudo cp etcdctl /usr/local/bin/	
    sudo cp etcdutl /usr/local/bin/
    
1.2. Предварительная проверка (можно пропустить)   
    ls -al /usr/local/bin/etcd*
    sudo /usr/local/bin/etcdctl version

1.3. Создание etcd.service
	
	sudo vi /etc/systemd/system/etcd.service
	
	[Unit]
	Description=etcd Server
	After=network.target
	After=network-online.target
	Wants=network-online.target

	[Service]
	Type=notify
	User=etcd
	ExecStart=/usr/local/bin/etcd  --config-file=/etc/etcd/etcd.yml
	#Restart=on-failure
	LimitNOFILE=65536

	[Install]
	WantedBy=multi-user.target
	
1.4. Перепрочтение конфигурационных файлов сервисов.

	sudo systemctl daemon-reload
	
1.5. Подготовка конфигурационный файлов /etc/etcd/etcd.yml

1.5.1 Создание файла /etc/etcd/etcd.yml на узле astra-etcd01 (etcd API v.3)

	sudo vi /etc/etcd/etcd.yml

	name: astra-etcd01 
        data-dir: /var/lib/etcd 
        hearbeat-interval: 100
        election-timeout: 1000
        initial-advertise-peer-urls: http://192.168.110.165:2380 
        listen-peer-urls: http://192.168.110.165:2380 
        listen-client-urls: http://192.168.110.165:2379,http://127.0.0.1:2379 
        advertise-client-urls: http://192.168.110.165:2379 
        initial-cluster-token: cluster-etcd 
        initial-cluster: astra-etcd01=http://192.168.110.165:2380
	auto-compaction-mode: periodic
	auto-compaction-retention: "24"
        initial-cluster-state: new	

1.5.2 Создание файла /etc/etcd/etcd.yml на узле astra-etcd02 (etcd API v.3)

	sudo vi /etc/etcd/etcd.yml
	
	name: astra-etcd02 
        data-dir: /var/lib/etcd 
        hearbeat-interval: 100
        election-timeout: 1000
        initial-advertise-peer-urls: http://192.168.110.166:2380 
        listen-peer-urls: http://192.168.110.166:2380 
        listen-client-urls: http://192.168.110.166:2379,http://127.0.0.1:2379 
        advertise-client-urls: http://192.168.110.166:2379 
        initial-cluster-token: cluster-etcd 
        initial-cluster: astra-etcd01=http://192.168.110.165:2380,astra-etcd02=http://192.168.110.166:2380  
	auto-compaction-mode: periodic
	auto-compaction-retention: "24"
        initial-cluster-state: existing

1.5.3 Создание файла /etc/etcd/etcd.yml на узле astra-etcd03 (etcd API v.3)

	sudo vi /etc/etcd/etcd.yml
	
	name: astra-etcd03
        data-dir: /var/lib/etcd 
        hearbeat-interval: 100
        election-timeout: 1000
        initial-advertise-peer-urls: http://192.168.110.167:2380 
        listen-peer-urls: http://192.168.110.167:2380 
        listen-client-urls: http://192.168.110.167:2379,http://127.0.0.1:2379 
        advertise-client-urls: http://192.168.110.167:2379 
        initial-cluster-token: cluster-etcd 
        initial-cluster: astra-etcd01=http://192.168.110.165:2380,astra-etcd02=http://192.168.110.166:2380,,astra-etcd03=http://192.168.110.166:2380  
	auto-compaction-mode: periodic
	auto-compaction-retention: "24"
        initial-cluster-state: existing



	
    
#### 1.4. Подготовка бинарных файлов etcd для работы.
1.4.1. Создаем каталог для скачивания etcd.

    sudo mkdir /tmp/etcd

1.4.2. Скачиваем крайнюю версию etcd. (Пример - 3.5.4)

    sudo curl -o /tmp/etcd/etcd-v3.5.4.tar.gz https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz
    
1.4.3. Раскрываем архив

    sudo tar -xvf /tmp/etcd/etcd-v3.5.4.tar.gz
    
1.4.4. Копируем бинарные файлы etcd.

Для RedOS,CentOS,RedHat:

    sudo cp /tmp/etcd/etcd* /usr/bin/
    
Для Astra Linux, Debian:

     sudo cp /tmp/etcd/etcd* /usr/local/bin/

#### 1.5. Подготовка конфигурационных файлов /etc/etcd/etcd.yml для создания кластера etcd


 


### Этап 2. Cоздание кластера etcd

#### 2.1. Конфигурирование кластера etcd

#### 2.2. Проверка работы кластера etcd

### Этап 3. Настройка авторизации в etcd


