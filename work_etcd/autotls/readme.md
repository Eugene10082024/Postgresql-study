### Результаты настройки autotls

Настроил кластер с одной node с etcd с работой по tls

Для настройки использовал следующие параметры конф. Файла etcd:

    client-transport-security:
      client-cert-auth: true
      auto-tls: true
    peer-transport-security:
      client-cert-auth: true
      auto-tls: true
    initial-cluster-state: new

[Полный конфигурационный файл можно посмотреть здесь. Пример 4]([https://github.com/Aleksey-10081967/Postgresql-study/tree/main/work_etcd/etcd_conf](https://github.com/Aleksey-10081967/Postgresql-study/tree/main/work_etcd/etcd_conf#%D0%B2%D0%B0%D1%80%D0%B8%D0%B0%D0%BD%D1%82-4-%D0%B8%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5-autotls--debug))

Сертификаты созданы в папке /var/lib/etcd/fixtures

При выполнении запросов к etcd с использованием сертификатов вылетает ошибка

    ETCDCTL_API=3 /usr/local/bin/etcdctl  --cert /var/lib/etcd/fixtures/client/cert.pem --key /var/lib/etcd/fixtures/client/key.pem -w table endpoint --cluster status

    {"level":"warn","ts":"2022-05-12T10:55:27.957+0300","logger":"etcd-client","caller":"v3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0000d28c0/127.0.0.1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"transport: authentication handshake failed: x509: certificate signed by unknown authority\""}
    Error: failed to fetch endpoints from etcd cluster member list: context deadline exceeded

Для получения ответа необходимо использовать –--insecure-skip-tls-verify

    ETCDCTL_API=3 /usr/local/bin/etcdctl  --insecure-skip-tls-verify --cert /var/lib/etcd/fixtures/client/cert.pem --key /var/lib/etcd/fixtures/client/key.pem -w table endpoint --cluster status


Также на сайте разработчика нашел рекомендацию – не использовать   auto-tls: true в промышленных средах.

However, --insecure-skip-tls-verify should only be used for testing purposes: it will disable all verification. I would not recommend auto-tls for production use. You can generate your own cert and CA with openssl or cfssl.

[Ссылка](https://github.com/etcd-io/etcd/issues/7654)
