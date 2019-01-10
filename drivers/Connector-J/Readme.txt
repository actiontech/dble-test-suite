1.config the environment
install JDK and set the corresponding environment variables(details please refer to the compose/install_jdk.sh)
2.package with maven on IntelliJ IDEA
1)open drivers/Connector-J in IntelliJ IDEA as maven project
2)package the jar with the steps:Maven projects -->install(note:the package should include all the assemblies: jars, classes, MANIFEST.MFS. )
3.run in commandline
1)access to the directory where the .jar file located
2)execute with the command: java -jar Jconnector-9.9.9.9.jar "test" "D:\autotest\dble\dble\conf\auto_dble_test.yaml" "driver_test_client.sql"