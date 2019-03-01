1.config the environment
install JDK and set the corresponding environment variables(details please refer to the compose/install_jdk.sh)

2.package with maven on IntelliJ IDEA
1)open drivers/Connector-J in IntelliJ IDEA as maven project
open project -> select the project dir
2)package the jar with the following command line:
mvn package
make sure "BUILD SUCCES" observed, after build success, generate "Jconnector-9.9.9.9.jar" under dir target/

3.run in commandline
1)access to the directory target/ where the .jar file located
2)execute with the command: java -jar Jconnector-9.9.9.9.jar "test" "D:\autotest\dble\dble\conf\auto_dble_test.yaml" "driver_test_client.sql"