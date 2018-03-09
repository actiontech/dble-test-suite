#environment
python 2.7.10
behave 1.2.5
mysql 5.7.13 / replication by gtid

#env prepare eg:
> cd compose
> mv docker-compose-agent.yml docker-compose.yml
> sudo docker-compose up -d --force-recreate //create inner containers
#Create /opt/auto_build directory to store various installation packages
#jdk-8u121-linux-x64.rpm, after decompression: mysql-5.7.13-linux-glibc2.5-x86_64, zookeeper-3.4.9
> bash en_dble.sh //initialize the inner containers

#use behave do test
#install from ftp
behave -D tar_local=false -D test_config=dble_auto_test.yaml features/install_uninstall/install_base.feature

#install from local
behave -D tar_local=true -D test_config=dble_auto_test.yaml features/install_uninstall/install_base.feature


#use drivers do test:
A. connector/c
#covers mysql interface_test
#step1:编译drivers/c_mysql_api/c_mysql_api.c文件, generate c_mysql_api.o：
gcc c_mysql_api.c -o c_mysql_api.o -I/opt/mysql-5.7.13-linux-glibc2.5-x86_64/include -L/opt/mysql-5.7.13-linux-glibc2.5-x86_64/lib -lmysqlclient

B. connector/j
#环境(already configured in agent docker)：
#java version "1.8.0_111"
#Java(TM) SE Runtime Environment (build 1.8.0_111-b14)
#Java HotSpot(TM) 64-Bit Server VM (build 25.111-b14, mixed mode)
#jdbc 5.1.39
#
#sqls.config is created to tell connector/j which sql files should be tested, its contents should keep consistent with read_write_split.feature/Scenario Outline:#1
#under folder drivers/java/ there are 3 jars, jsch-0.1.54.jar is a ssh-similar-func jar,mysql-connector-java-5.1.39-bin.jar is the jdbc jar, test.jar is exported for test
step1:open drivers/java-project in eclipse, then export read_write_split.jar to drivers/java
      how: right click->export->java/JAR file->input destination->next check MANIFEST is the right one->finish
step2: cd drivers/java && bash ln.sh
Step3:cd drivers/java 执行
	java -jar read_write_split.jar | tee output.log 2>&1
    java -jar interface_test.jar | tee output.log 2>&1
	如果打印调试信息：java -jar interface_test.jar debug| tee output.log 2>&1