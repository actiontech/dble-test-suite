PWD = $(shell pwd)

docker_up:
	docker-compose -f $(PWD)/compose/docker-compose.yml up -d --force

create_vene:
	pipenv install

run_cluster:
    pipenv run behave -Dis_cluster=true -Dreset=true features/install_uninstall/single_dble_and_zk_cluster.feature \
    features/install_uninstall/install_dble_cluster.feature \
    features/cluster/ \
    features/install_uninstall/stop_dble_cluster.feature

run_func_test:
    pipenv run behave -Dreset=true -D dble_conf=template features/install_uninstall/install_dble.feature features/func_test

resetRp:
	bash $(PWD)/compose/docker-build-behave/resetReplication.sh

run_sql_support_special: resetRp
	pipenv run behave -D dble_conf=sql_cover_mixed features/install_uninstall/install_dble.feature \
	features/sql_cover/special/

run_sql_support_global: 
	pipenv run behave -D dble_conf=sql_cover_global features/sql_cover/sql_global.feature

run_sql_support_no_sharding:
	pipenv run behave -D dble_conf=sql_cover_nosharding features/sql_cover/sql_nosharding.feature

run_sql_support_sharding: 
	pipenv run behave -D dble_conf=sql_cover_sharding features/sql_cover/sql_sharding.feature

run_sql_support_mix: 
	pipenv run behave -D dble_conf=sql_cover_mixed features/sql_cover/sql_mixed.feature
