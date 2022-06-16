### Примеры etcd.conf

#### Вариант 1. Использование IP адресов 
            name: astra-etcd01 
            data-dir: /var/lib/etcd 
            enable-v2: true 
            hearbeat-interval: 200
            election-timeout: 2000
            initial-advertise-peer-urls: http://192.168.110.165:2380 
            listen-peer-urls: http://192.168.110.165:2380 
            listen-client-urls: http://192.168.110.165:2379,http://127.0.0.1:2379 
            advertise-client-urls: http://192.168.110.165:2379 
            initial-cluster-token: cluster-etcd 
            initial-cluster: astra-etcd01=http://192.168.110.165:2380,astra-etcd02=http://192.168.110.166:2380,astra-etcd03=http://192.168.110.167:2380  
            initial-cluster-state: new

#### Вариант 2. Использование FQDN в параметрах, где это разрешено

            name: kis-etcd01
            data-dir: /var/lib/etcd
            enable-v2: true
            heartbeat-interval: 400
            election-timeout: 4000
            initial-advertise-peer-urls: http://vdc01-testn1.test.ru:2380
            listen-peer-urls: http://10.2.7.133:2380
            listen-client-urls: http://10.2.7.133:2379,http://127.0.0.1:2379
            advertise-client-urls: http://vdc01-testn1.test.ru:2379
            initial-cluster-token: cluster-kis-etcd
            initial-cluster: kis-etcd01=http://vdc01-testn1.test.ru:2380,kis-etcd02=http://vvdc01-testn2.test.ru:2380,kisupd-etcd03=http://vvdc01-testn3.test.ru:2380
            initial-cluster-state: existing

#### Вариант 3. использование autotls + debug 

В данном варианте обратите внимание на отступы в соответствующих группах. etcd.conf - есть yml файл

            name: kis-etcd01
            data-dir: /var/lib/etcd
            enable-v2: true
            initial-advertise-peer-urls: https://vdc01-testn1.test.ru:2380
            listen-peer-urls: https://10.2.7.133:2380
            listen-client-urls: https://10.2.7.133:2379,https://127.0.0.1:2379
            advertise-client-urls: https://vdc01-testn1.test.ru:2379
            initial-cluster-token: cluster-kis-etcd
            initial-cluster: kisupd-etcd01=https://vdc01-testn1.test.ru:2380
            client-transport-security:
              client-cert-auth: true
              auto-tls: true
            peer-transport-security:
              client-cert-auth: true
              auto-tls: true
            initial-cluster-state: new
            log-level: debug

[Пример etcd.conf от разработчика со всеми параметрами](https://github.com/etcd-io/etcd/blob/main/etcd.conf.yml.sample) 
