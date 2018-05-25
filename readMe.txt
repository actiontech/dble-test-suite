
一、环境搭建参考：compose/README.txt

二、对connector/c中接口的支持度测试
#step1:编译drivers/c_mysql_api/c_mysql_api.c文件, 生成 c_mysql_api.o：
gcc c_mysql_api.c -o c_mysql_api.o -I/opt/mysql-5.7.13-linux-glibc2.5-x86_64/include -L/opt/mysql-5.7.13-linux-glibc2.5-x86_64/lib -lmysqlclient
#step2:运行
./c_mysql_api.o

三、对connector/j中接口及sql的支持度测试
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

四、使用MySQLdb驱动测试dble对sql的支持度（use behave)
# behave 自定义命令行参数说明：
# -D tar_local={true|false}, default false, change in behave.ini as you need
# -D test_config={auto_dble_test.yaml}
# -D reinstall=true, default false, true is a must for install related features

#集群到单节点
behave -Dreinstall=true -Dis_cluster=true features/install_uninstall/install_base.feature

#通过ftp包安装单节点并启动
behave -Dreinstall=true features/install_uninstall/install_dble.feature

#更新dble单节点
behave -Dreinstall=true features/install_uninstall/update_dble.feature

#通过ftp包解压安装到所有节点，配置使用zk，启动所有节点
behave -Dreinstall=true -Dis_cluster=true features/install_uninstall/install_dble_and_zk.feature

#sql覆盖
behave -D dble_conf=sql_cover features/sql_cover/sql.feature features/sql_cover/manager.feature

#算法
behave -D dble_conf=template features/function/

#配置
behave -D dble_conf=template features/reload_conf/

#全局序列(本地文件)
behave -D dble_conf=template features/sequence/sequence.feature

#安全性
behave -D dble_conf=template features/safety/safety.feature

=========================zk 使用说明=======================
1, dble/conf/myid.properties配置：
#set false if not use cluster ucore/zk
cluster=zk
#client info
ipAddress=127.0.0.1
port=2181
#cluster namespace, please use the same one in one cluster
clusterId=cluster-1
#it must be different for every node in cluster
2, zookeeper/conf/zoo.cfg配置:
tickTime=2000
initLimit=10
syncLimit=5
clientPort=2181
dataDir=/opt/zookeeper/data
dataLoginDir=/opt/zookeeper/logs
server.1=dble-1:2888:3888
server.2=dble-2:2888:3888
server.3=dble-3:2888:3888
3, under zookeeper/data, create myid file, content eg:
2
4,start all zk servers by "zkServer.sh start" before view status with 'zkServer.sh status'

#todo:
2会话并发交替
1, block确认
2, hang后超时多久连接重建