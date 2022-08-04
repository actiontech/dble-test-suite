PWD = $(shell pwd)

create_vene:
	pipenv install
	
resetRp:
	bash $(PWD)/compose/docker-build-behave/resetReplication.sh

run_func_test: resetRp
	pipenv run behave -Dreset=false -D dble_conf=template features/install_uninstall/install_dble.feature \
	features/func_test

run_sql_support_special: resetRp
	pipenv run behave -D dble_conf=sql_cover_mixed features/install_uninstall/install_dble.feature \
	features/sql_cover/special/

run_sql_support_global: 
	pipenv run behave -D dble_conf=sql_cover_global features/install_uninstall/install_dble.feature \
 	features/sql_cover/sql_global.feature

run_sql_support_no_sharding:
	pipenv run behave -D dble_conf=sql_cover_nosharding features/install_uninstall/install_dble.feature \
	features/sql_cover/sql_nosharding.feature

run_sql_support_sharding: 
	pipenv run behave -D dble_conf=sql_cover_sharding features/install_uninstall/install_dble.feature \
	features/sql_cover/sql_sharding.feature	

run_sql_support_mix: 
	pipenv run behave -D dble_conf=sql_cover_mixed features/install_uninstall/install_dble.feature \
	features/sql_cover/sql_mixed.feature
