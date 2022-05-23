
## 一、环境搭建
参考：./behave_dble/compose/README.md

## 二、对connector/c中接口的支持度测试
参考：drivers/c_mysql_api下对应文件夹中的README.md

## 三、对connector/j中接口及sql的支持度测试
环境(already configured in agent docker)：
java version "1.8.0_111"
Java(TM) SE Runtime Environment (build 1.8.0_111-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.111-b14, mixed mode)
jdbc 5.1.39

> sqls.config is created to tell connector/j which sql files should be tested, its contents should keep consistent with read_write_split.feature/Scenario Outline:#1

> under folder drivers/java/ there are 3 jars, jsch-0.1.54.jar is a ssh-similar-func jar,mysql-connector-java-5.1.39-bin.jar is the jdbc jar, test.jar is exported for test

1. open drivers/java-project in eclipse, then export read_write_split.jar to drivers/java
      how: right click->export->java/JAR file->input destination->next check MANIFEST is the right one->finish
2. cd drivers/java && bash ln.sh
3. cd drivers/java 执行
	java -jar read_write_split.jar | tee output.log 2>&1
    java -jar interface_test.jar | tee output.log 2>&1
	如果打印调试信息：java -jar interface_test.jar debug| tee output.log 2>&1

## 四、使用behave测试dble(以下涉及的behave命令需要在behave_dble目录下执行)
### behave 自定义命令行参数说明（change in behave.ini as your need）：
 - -D install_from_local={true|false}, default false
 - -D test_config={auto_dble_test.yaml}
 - -D reinstall=true, default false, true if need reinstall before features start
 - -D reset=true, reset dble config files and restart dble before features start
 
 
### Scenario中的tags使用说明
#### behave_dble下的用例按照 allure-behave将用例优先级由高到低分为以下5类:
- BLOCKER
- CRITICAL
- NORMAL
- MINOR
- TRIVIAL
#### 用于scenario执行后的环境恢复，以免影响后续用例的执行
- restore_sys_time --恢复系统时间到当前时间，目前用于全局序列的用例中
- aft_reset_replication --重置MySQL数据库中的数据并且恢复复制关系，目前此tag涉及的方法用于4种类型的sql覆盖中
- restore_network --删除已设置的防火前规则，一般用于使用iptables命令加了防火墙规则的场景
- restore_view --删除已建立的view，防止dble日志中出现报错信息，一般用于创建了view的场景
- restore_mysql_service --启动已停止的MySQL服务，一般用于用例中有停止MySQL服务的场景
- restore_global_setting --还原MySQL中全局变量值到默认值，一般用于用例中有改变MySQL默认全局变量值的场景
- restore_mysql_config --还原MySQL的配置值到初始值，一般用于用例中有改变MySQL配置值的场景
#### 其他tags参数说明
- btrace --用于标注此scenario用到了btrace插桩，便于后续统一管理
- skip_restart --scenario结束之后保持当前的配置，且不会重启dble，一般用于前后scenario有关联的场景或者scenario运行失败时的原因分析


### 测试命令集
#### 1.通过ftp包安装单节点并启动
behave -Dreset=false features/install_uninstall/install_dble.feature

#### 2.通过ftp包解压安装dble到所有节点，配置使用zk，启动集群内所有节点(-Dreset=false 参数仅为初始安装dble的必要参数)
behave -Dreset=false -Dis_cluster=true features/install_uninstall/install_dble_cluster.feature 

#### 3.通过ftp包解压安装dble到所有节点，配置使用zk，启动所有节点，集群到单节点转换(-Dreset=false 参数仅为初始安装dble的必要参数)
behave -Dreset=false -Dis_cluster=true features/install_uninstall/single_dble_and_zk_cluster.feature

#### 4.使用特定配置启动dble
behave --stop -D dble_conf={sql_cover_sharding | sql_cover_nosharding | sql_cover_global | sql_cover_mixed | template} features/setup.feature

#### 5.各种表类型的sql覆盖测试
- sqls_mixed: 用于默认sql覆盖，包含混合表类型
- sqls_util: 所有表类型的sql覆盖都需要分别覆盖

#### 6.不适合批量测试的特殊sql语句的测试专项覆盖
behave -D dble_conf=sql_cover_mixed features/sql_cover/special/

#### 7.全局表sql测试套件覆盖
behave -Ddble_conf=sql_cover_global features/sql_cover/sql_global.feature

#### 8.混合类型表sql测试套件覆盖
behave -Ddble_conf=sql_cover_mixed features/sql_cover/sql_mixed.feature

#### 9.分片表sql测试套件覆盖
behave -Ddble_conf=sql_cover_sharding features/sql_cover/sql_sharding.feature

#### 10.非分片表sql测试套件覆盖
behave --stop -Ddble_conf=sql_cover_nosharding features/sql_cover/sql_nosharding.feature

#### 11.分片算法测试套件覆盖
behave -D dble_conf=template features/func_test/sharding_func_test/

#### 12.配置测试套件覆盖
behave -D dble_conf=template features/func_test/cfg_test/

#### 13.全局序列功能测试
behave -D dble_conf=template features/func_test/sequence/sequence.feature

#### 14.安全性测试套件覆盖
behave -D dble_conf=template features/func_test/safety/safety.feature

#### 15.运维命令测试套件覆盖
behave -D dble_conf=template features/func_test/managercmd/

### zk 使用说明
#### 1.更新dble/conf/cluster.cnf配置：
```
#set false if not use cluster ucore/zk
cluster=zk
#client info
ipAddress=127.0.0.1:2181
#cluster namespace, please use the same one in one cluster
clusterId=cluster-1
#it must be different for every node in cluster
```
#### 2.zookeeper/conf/zoo.cfg配置:
```
tickTime=2000
initLimit=10
syncLimit=5
clientPort=2181
dataDir=/opt/zookeeper/data
dataLoginDir=/opt/zookeeper/logs
server.1=dble-1:2888:3888
server.2=dble-2:2888:3888
server.3=dble-3:2888:3888
```
#### 3.under zookeeper/data, create myid file, fill content eg:
```
2
```

#### 4.start all zk servers by "zkServer.sh start", then view status with 'zkServer.sh status'
