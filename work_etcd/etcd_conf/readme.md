### Примеры etcd.conf

#### Вариант 1.


#### Вариант 2.

Показано в каких параметрам можно использовать FQDN, а в каких НЕТ.

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
й
