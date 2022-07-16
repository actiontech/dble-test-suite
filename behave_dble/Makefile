ifndef DBLE_DBLE_TOPO
	DBLE_DBLE_TOPO = single
endif

PWD = $(shell pwd)
DOCKER_COMPOSE_FILE = docker-compose_${DBLE_DBLE_TOPO}.yml

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

run_cluster_case: up
	pipenv run behave features/setup.feature \
	features/cluster/ \
	features/install_uninstall/stop_dble_cluster.feature

run_func_stable_case: up
	pipenv run behave -Dreset=true -D dble_conf=template features/setup.feature \
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


run_func_unstable_case: up
	pipenv run behave -Dreset=true -D dble_conf=template features/setup.feature \
	features/func_test/flow_control/ \
	features/func_test/connection/  \
	features/func_test/ddl/  \
	features/func_test/xa_transaction/ \
	features/func_test/Large_Packet/

run_func_case: up
	pipenv run behave -Dreset=false -D dble_conf=template features/setup.feature \
	features/func_test

run_managercmd_case: up
	pipenv run behave -Dreset=false -D dble_conf=template features/setup.feature \
	features/func_test/dble_information/ \
	features/func_test/managercmd/

run_sql_support_special: up
	pipenv run behave -Dreset=false -D dble_conf=sql_cover_mixed features/setup.feature \
	features/sql_cover/special/

run_sql_support_global: 
	pipenv run behave -D dble_conf=sql_cover_global features/sql_cover/sql_global.feature

run_sql_support_no_sharding:
	pipenv run behave -D dble_conf=sql_cover_nosharding features/sql_cover/sql_nosharding.feature

run_sql_support_sharding:
	pipenv run behave -D dble_conf=sql_cover_sharding features/sql_cover/sql_sharding.feature	

run_sql_support_special:
	pipenv run behave -D dble_conf=sql_cover_mixed features/sql_cover/sql_mixed.featur