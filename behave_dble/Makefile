ifndef DBLE_DBLE_TOPO
	DBLE_DBLE_TOPO = single
endif

PWD = $(shell pwd)
DRIVER_DIR = $(shell dirname ${PWD})
DOCKER_COMPOSE_FILE = docker-compose-${DBLE_DBLE_TOPO}.yml

up: down
	docker-compose -f ${PWD}/compose/${DOCKER_COMPOSE_FILE} up -d
	sleep 3
	date

clean: down remove_venv
	docker system prune -fa

down:
	docker ps -a -q | xargs -r docker rm -f
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

run_cluster_case: up
	pipenv run behave features/setup.feature \
	features/cluster/cluster_check_table_view.feature \
	features/cluster/cluster_check_table_ddl.feature \
	features/cluster/cluster_check_zk_binlog.feature \
	features/cluster/cluster_detach_attach.feature \
	features/cluster/kill_ddl_lock.feature:8 \
	features/cluster/cluster_xml_to_json.feature:9 \
	features/cluster/cluster_check_reload.feature:855
	
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
	features/func_test/cfg_test/dbInstance_load_balance.feature:441 \
    features/func_test/cfg_test/schema_funcation.feature:377 \
	features/func_test/cfg_test/user.feature:267 \
    features/func_test/connection/connection_pool_heartbeat_test.feature:83 \
    features/func_test/connection/connection_pool_basic_test.feature \
    features/func_test/dble_information/dble_table_group.feature \
	features/func_test/dble_information/sql_log.feature:1218 \
	features/func_test/dble_information/sql_statistic_queue_monitor.feature \
	features/func_test/dble_information/backend_variables.feature:8 \
    features/func_test/managercmd/python_mysql_ha.feature \
    features/func_test/managercmd/pause_resume.feature:31 \
    features/func_test/ddl/ddl_refactor.feature:72 \
    features/func_test/special/complex_query_npe.feature:9 \
    features/func_test/heartbeat/db_heartbeat_keepAlive.feature:10 \
    features/func_test/heartbeat/kill_heartbeat_connection.feature \
    features/func_test/load_data/load_data_batch.feature \
    features/func_test/sequence/sequence.feature:68 \
    features/func_test/xa_transaction/xa_retry_count.feature:96 \
    features/func_test/cfg_test/sharding_db_attribute.feature:240 \
    features/func_test/heartbeat/reconnect_heartbeat_readonly_check.feature:349 \
    features/func_test/connection/rwSplit_connection_test.feature \
    features/func_test/xa_transaction/net_down_before_rollback.feature:15 \
    features/func_test/managercmd/reload_lock.feature:9 \
    features/func_test/safety/mysql_node_disconnected.feature:58 \
    features/func_test/managercmd/reload_config_all.feature:62 \
    features/func_test/cfg_test/user.feature:298

run_func_unstable_case: up
	pipenv run behave -D dble_conf=template features/setup.feature \
	features/func_test/flow_control/ \
	features/func_test/connection/  \
	features/func_test/ddl/  \
	features/func_test/xa_transaction/ \
	features/func_test/local_read/ \
	features/func_test/Large_Packet/

run_managercmd_case: up
	pipenv run behave -Dreset=false -D dble_conf=template features/setup.feature \
	features/func_test/dble_information/ \
	features/func_test/managercmd/

run_sql_support_special: up
	pipenv run behave -Dreset=false -D dble_conf=sql_cover_mixed features/setup.feature \
	features/sql_cover/special/subquery_plan_optimize.feature:8

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
