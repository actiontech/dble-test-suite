ifndef DBLE_DBLE_TOPO
	DBLE_DBLE_TOPO = single
endif

PWD = $(shell pwd)
DRIVER_DIR = $(shell dirname ${PWD})
DOCKER_COMPOSE_FILE = docker-compose-${DBLE_DBLE_TOPO}.yml
DOCKER_RUNNING = $(shell docker ps -q | wc -l)
DOCKER_EXISTS = $(shell docker ps -aq | wc -l)


up: down
	docker-compose -f ${PWD}/compose/${DOCKER_COMPOSE_FILE} up -d
	sleep 3
	date

clean: down remove_venv
	docker system prune -fa

down:
    ifneq ($(DOCKER_RUNNING),0)
		docker stop $$(docker ps -q)
    endif

    ifneq ($(DOCKER_EXISTS),0)
		docker rm $$(docker ps -a -q)
    endif

	docker network prune -f
	docker volume prune -f

create_venv:
	pipenv install

remove_venv:
	pipenv --rm

venv:
	pipenv shell

reset_mysql:
	pipenv run behave features/setup.feature --tags=@Initialize_mysql

used_in_local: create_venv up
	pipenv run behave features/setup.feature

##debug pipline
run_cluster_case1: up
	pipenv run behave features/setup.feature \
	features/cluster/kill_ddl_lock.feature \

run_cfg_case1: up
	pipenv run behave -D dble_conf=template features/setup.feature \
	features/func_test/connection/rwSplit_connection_test.feature



##clone pipline
run_cluster_unstable_case: up
	pipenv run behave features/setup.feature \
	features/cluster/ruleFile.feature \


run_cfg_case_unstable: up
	pipenv run behave -D dble_conf=template features/setup.feature \
	features/func_test/tmp_case/ \
	features/func_test/Large_Packet/


##master pipline
run_cluster_case: up
	pipenv run behave features/setup.feature \
	features/cluster/check_full_meta_in_cluster.feature \
	features/cluster/cluster_check_ddl_log.feature \
	features/cluster/cluster_check_Ha.feature \
	features/cluster/cluster_check_pause_resume.feature \
	features/cluster/cluster_check_reload.feature \
	features/cluster/cluster_check_start.feature \
	features/cluster/cluster_check_table_ddl.feature \
	features/cluster/cluster_check_table_view.feature \
	features/cluster/cluster_check_xa.feature \
	features/cluster/cluster_check_zk_binlog.feature \
	features/cluster/cluster_detach_attach.feature \
	features/cluster/cluster_file_syn.feature \
	features/cluster/cluster_txIsolation.feature \
	features/cluster/cluster_xml_to_json.feature \
	features/cluster/kill_ddl_lock.feature \
	features/cluster/show_ddl.feature \
	features/cluster/writeHost_support_weight.feature \
	features/cluster/xml_exception_case.feature \
	features/cluster/xml_version_check.feature \
	features/cluster/zk_global_sequence.feature \
	features/cluster/zk_onlinekey_check.feature \
	features/cluster/zk_sequence.feature \

run_func_stable_case: up
	pipenv run behave -D dble_conf=template features/setup.feature \
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

run_cfg_case: up
	pipenv run behave -D dble_conf=template features/setup.feature \
	features/func_test/cfg_test/

run_func_unstable_case: up
	pipenv run behave -D dble_conf=template features/setup.feature \
	features/func_test/flow_control/ \
	features/func_test/connection/  \
	features/func_test/ddl/  \
	features/func_test/xa_transaction/ \

run_managercmd_case: up
	pipenv run behave -Dreset=false -D dble_conf=template features/setup.feature \
	features/func_test/dble_information/ \
	features/func_test/managercmd/

run_sql_support_special: up
	pipenv run behave -Dreset=false -D dble_conf=sql_cover_mixed features/setup.feature \
	features/sql_cover/special/

run_sql_support_global: up
	pipenv run behave -D dble_conf=sql_cover_global features/setup.feature features/sql_cover/sql_global.feature

run_sql_support_no_sharding:up
	pipenv run behave -D dble_conf=sql_cover_nosharding features/setup.feature features/sql_cover/sql_nosharding.feature

run_sql_support_sharding: up
	pipenv run behave -D dble_conf=sql_cover_sharding features/setup.feature features/sql_cover/sql_sharding.feature

run_sql_support_mix: up
	pipenv run behave -D dble_conf=sql_cover_mixed  features/setup.feature features/sql_cover/sql_mixed.feature

run_connector_dotnet: up
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/Connector-.Net/run_connector_dotnet.sh

run_connector_J: up
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/Connector-J/run_connector_J.sh

run_jdbc_api_test:
	bash ${DRIVER_DIR}/drivers/jdbc-api-test/jdbc-api-test-start.sh

run_multiQuery: up
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/c_mysql_api/multi-queries/multiQuery.sh

run_connector_cpp: up
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/Connector-cpp/run_connector_cpp.sh

run_c_mysql_api: up
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/c_mysql_api/src/c_mysql_api.sh
