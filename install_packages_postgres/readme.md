### Развертывание пакетов Postgresql для кластера Patroni
Для примера в кластере Patroni будут использованы 2 узла с postgresql:
1. Узел 1 - redoc-7.3-pgs01 - IP 192.168.122.170
2. Узел 2 - redoc-7.3-pgs01 - IP 192.168.122.171

1. Развертывание необходимых пакетов:

1.1. Развертывание необходимых пакетов postgrespro-ent (на примере postgrespro-ent-14)

	sudo dnf install ./postgrespro-ent-14-libs-14.6.1-1.el7.x86_64.rpm
	sudo dnf install ./postgrespro-ent-14-client-14.6.1-1.el7.x86_64.rpm
	sudo dnf install ./postgrespro-ent-14-server-14.6.1-1.el7.x86_64.rpm
	sudo dnf install ./postgrespro-ent-14-contrib-14.6.1-1.el7.x86_64.rpm

1.2. Развертывание пакетов postgrespro-std (на примере postgrespro-std-14)


1.3. Развертывание пакетов postgresql (на примере postgresql 14)

2. Смена домашнего каталога у пользователя postgres и создание каталогов для postgresqlpro.

    	sudo usermod -d /home/postgres postgres
	su - postgres
		
3. Создание каталогов для postgres. (каталог данных)

	sudo mkdir -p /pgdata/14/data
	sudo chown -R postgres:postgres /pgdata/14
	sudo chmod -R 700 /pgdata/14
		
4. Каталог log (при необходимости): 

	sudo mkdir -p /pgdata/log
	sudo chown -R postgres:postgres /pgdata/log
	
5. Каталог WAL (при необходимости):

	sudo mkdir -p /pgwal/wal/wal
	sudo chown -R postgres:postgres /pgwal/wal/
	sudo chmod -R 700 /pgwal/wal
	
6.  Каталог для архивных WAL (при необходимости):	

	sudo mkdir -p /pgwalarch/walarch
	sudo chown -R postgres:postgres  /pgwalarch/walarch
	sudo chmod -R 700 /pgwalarch/walarch
