### Создание кластера etcd для работы с Patroni
Создание кластера etcd для работы с Patroni включаем в себя следующие этапы:

1. Развертывание etcd на узлы планируемого кластера
2. Создание кластера etcd
3. Настройка авторизации в etcd

В примере для развертывания и настройки кластера etcd будет использовано три узла:

    astra-etcd01 - 192.168.122.165
    astra-etcd02 - 192.168.122.166
    astra-etcd03 - 192.168.122.167

В качестве ОС используется Astra Linux SE 1.6. Для развертывания кластера etcd это не принципиально.

#### Развертывание etcd на узлы планируемого кластера

Все описанные действия в данном пункте необходимо выполнить на каждом узле кластера.

##### 1. Создание группы etcd.
    groupadd --system etcd
    
##### 2. Создание пользователя etcd:
    useradd --home-dir "/var/lib/etcd" --system --shell /bin/false -g etcd etcd

##### 3. Создание необходимых каталогов.

3.1. Каталог для конфигурационного файла etcd.yml

    mkdir -p /etc/etcd
  
3.2. Создание каталога для БД etcd  

    mkdir -p /var/lib/etcd
    
3.3. Назначение владельцем созданных каталогов пользователя etcd:

    chown etcd:etcd /etc/etcd    
    chown etcd:etcd /var/lib/etcd

3.4. Смена прав доступа к каталогу /var/lib/etcd:

    chmod -R 700 /var/lib/etcd
    
##### 4. Подготовка бинарных файлов etcd для работы.
4.1. Создаем каталог для скачивания etcd.

    sudo mkdir /tmp/etcd

4.2. Скачиваем крайнюю версию etcd. Сейчас это 3.5.4

    sudo curl -o /tmp/etcd/etcd-v3.5.4.tar.gz https://github.com/etcd-io/etcd/releases/download/v3.5.4/etcd-v3.5.4-linux-amd64.tar.gz
    
4.3. Раскрываем архив

    sudo tar -xvf /tmp/etcd/etcd-v3.5.4.tar.gz
    
4.4. Копируем бинарные файлы etcd.

Для RedOS,CentOS,RedHat:

    sudo cp /tmp/etcd/etcd* /usr/bin/
    
Для Astra Linux, Debian:

     sudo cp /tmp/etcd/etcd* /usr/local/bin/


