1.config the environment
install JDK and set the corresponding environment variables(details please refer to the compose/install_jdk.sh)

2.package with maven on IntelliJ IDEA
1)open drivers/Connector-J in IntelliJ IDEA as maven project
open project -> select the project dir
2)package the jar with the following command line:
mvn package
make sure "BUILD SUCCES" observed, after build success, generate "Jconnector-5.1.35.jar" under dir target/

3.执行：behave --stop -D dble_conf=sql_cover_sharding features/setup.feature

4.run in commandline
1)access to the directory Connector-J/
2)execute with the command: java -jar target/Jconnector.jar "" "/opt/auto_test/dble/behave_dble/conf/auto_dble_test.yaml" "driver_test_client.sql" "driver_test_manager.sql"