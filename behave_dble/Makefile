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

run_cluster_case: up
	pipenv run behave features/setup.feature \features/cluster/cluster_check_table_view.feature \
	features/cluster/kill_ddl_lock.feature \
	features/cluster/cluster_check_reload.feature \
	features/cluster/writeHost_support_weight.feature \
	features/cluster/show_ddl.feature \
	features/cluster/cluster_xml_to_json.feature \


run_cluster_unstable_case: up
	pipenv run behave features/setup.feature \
	features/cluster/cluster_check_table_ddl.feature \
	features/cluster/cluster_check_zk_binlog.feature \
	features/cluster/cluster_detach_attach.feature \


run_cfg_case1: up
	pipenv run behave -D dble_conf=template features/setup.feature \
	features/func_test/cfg_test/schema_funcation.feature \
	features/func_test/cfg_test/user.feature \
	features/func_test/cfg_test/user_analysisUser.feature \
	features/func_test/cfg_test/mulitiple_reload.feature \
	features/func_test/cfg_test/db_value_incorrect.feature \
	features/func_test/connection/connection_pool_basic_test.feature \
	features/func_test/dble_information/dble_table_group.feature \
	features/func_test/dble_information/sql_log.feature \
	features/func_test/dble_information/backend_variables.feature \
	features/func_test/dble_information/backend_connections.feature \
	features/func_test/dble_information/dble_thread_pool.feature \
	features/func_test/dble_information/dble_xa_session.feature \
	features/func_test/dble_information/sql_statistic.feature \
	features/func_test/managercmd/python_mysql_ha.feature \
	features/func_test/managercmd/pause_resume.feature \
	features/func_test/managercmd/reload_config_all.feature \
	features/func_test/managercmd/check_global.feature \
	features/func_test/managercmd/reload_config_all_r.feature \
	features/func_test/managercmd/reload_lock.feature \
	features/func_test/managercmd/show_connection.feature \
	features/func_test/managercmd/slow_query.feature \
	features/func_test/managercmd/show_sqlX.feature \


run_cfg_case2: up
	pipenv run behave -D dble_conf=template features/setup.feature \
	features/func_test/Large_Packet/Large_Packet.feature \
	features/func_test/ddl/ddl_refactor.feature \
	features/func_test/special/complex_query_npe.feature \
	features/func_test/special/fingerprint_log.feature \
	features/sql_cover/special/hint.feature \
	features/func_test/sequence/sequence.feature \
	features/func_test/safety/mysql_node_disconnected.feature \
	features/func_test/heartbeat/kill_heartbeat_connection.feature \
	features/func_test/xa_transaction/xa_retry_count.feature \
	features/func_test/metalock/mysql_slave_down.feature \


run_cfg_case_unstable: up
	pipenv run behave -D dble_conf=template features/setup.feature \
	features/func_test/dble_information/dble_xa_recover.feature \
	features/func_test/dble_information/sql_statistic_queue_monitor.feature \
	features/func_test/connection/connection_pool_heartbeat_test.feature \
	features/func_test/connection/rwSplit_connection_test.feature \
	features/func_test/cfg_test/dbInstance_load_balance.feature \
	features/func_test/cfg_test/sharding_db_attribute.feature \
	features/func_test/cfg_test/general_log.feature \
	features/func_test/managercmd/split.feature \
	features/func_test/xa_transaction/net_down_before_rollback.feature \


run_cfg_case_unstable2: up
	pipenv run behave -D dble_conf=template features/setup.feature \
	features/func_test/heartbeat/reconnect_heartbeat_readonly_check.feature \
	features/func_test/heartbeat/db_heartbeat_keepAlive.feature \
	features/func_test/load_data/load_data_batch.feature \
	features/func_test/xa_transaction/bg_strategy_after_net_shock.feature \
	features/func_test/xa_transaction/bg_strategy_after_node_hangs.feature \
	features/func_test/special/thread_leak_test.feature  \
	features/func_test/sql_plan/hint_planA_3.feature  \
	features/func_test/sql_plan/hint_planA_4.feature  \
	features/func_test/sql_plan/hint_planA_5.feature  \
	features/func_test/sql_plan/hint_planA_6.feature  \
	features/func_test/sql_plan/useNewJoinOptimizer1.feature \



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
