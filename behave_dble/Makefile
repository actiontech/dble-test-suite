PWD = $(shell pwd)

docker_up:
	docker-compose -f $(PWD)/compose/docker-compose.yml up -d --force

create_vene:
	pipenv install

run_cfg_case: resetRp
	pipenv run behave -Dreset=true -D dble_conf=template features/install_uninstall/install_dble.feature \
	features/func_test/cfg_test/

run_func_stable_case: resetRp
	pipenv run behave -Dreset=true -D dble_conf=template features/install_uninstall/install_dble.feature \
	features/func_test/global_var_init/ \
	features/func_test/load_data/  \
	features/func_test/safety/  \
	features/func_test/sequence/  \
	features/func_test/sharding_func_test/  \
	features/func_test/slow_log/  \
	features/func_test/special/ \
	features/func_test/sql_plan/ \
	features/func_test/trace/  \
	features/func_test/heartbeat/ \
	features/func_test/metalock/

run_func_unstable_case: resetRp
	pipenv run behave -Dreset=true -D dble_conf=template features/install_uninstall/install_dble.feature \
	features/func_test/flow_control/ \
	features/func_test/connection/  \
	features/func_test/ddl/  \
	features/func_test/xa_transaction/ \
	features/func_test/Large_Packet/

run_managercmd_case: resetRp
	pipenv run behave -Dreset=true -D dble_conf=template features/install_uninstall/install_dble.feature \
	features/func_test/dble_information/ \
	features/func_test/managercmd/

run_cluster:
	pipenv run behave -Dis_cluster=true -Dreset=true features/install_uninstall/single_dble_and_zk_cluster.feature \
	features/install_uninstall/install_dble_cluster.feature \
	features/cluster/ \
	features/install_uninstall/stop_dble_cluster.feature

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
