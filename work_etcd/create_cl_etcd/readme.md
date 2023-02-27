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
	ls -al /usr/local/bin/etcd*
	sudo /usr/local/bin/etcdctl version


    
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


