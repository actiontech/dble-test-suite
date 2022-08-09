PWD = $(shell pwd)
DRIVER_DIR = $(shell dirname ${PWD})


run_sql_support_special:
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

run_connector_dotnet:
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/Connector-.Net/run_connector_dotnet.sh

run_connector_J:
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/Connector-J/run_connector_J.sh

run_jdbc_api_test:
	bash ${DRIVER_DIR}/drivers/jdbc-api-test/jdbc-api-test-start.sh

run_multiQuery:
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/c_mysql_api/multi-queries/multiQuery.sh

run_connector_cpp:
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/Connector-cpp/run_connector_cpp.sh

run_c_mysql_api:
	pipenv run behave --stop -D dble_conf=sql_cover_sharding features/setup.feature
	bash ${DRIVER_DIR}/drivers/c_mysql_api/src/c_mysql_api.sh

