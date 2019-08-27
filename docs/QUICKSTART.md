
## 一. 测试环境搭建
参考：./behave_dble/compose/README.md

## 二. 使用behave测试dble(以下涉及的behave命令需要在behave_dble目录下执行)
### behave 自定义命令行参数说明（在 behave.ini 中配置）：
 - -D install_from_local={true|false}, default false
 - -D test_config={auto_dble_test.yaml}，测试使用的配置文件
 - -D reinstall={true|false}，default false, true if need reinstall before features start
 - -D reset={true|false}, default true, reset dble config files and restart dble before features start
- -D dble_conf = {sql_cover_mixed|sql_cover_global|template|sql_cover_nosharding|sql_cover_sharding}, default template
- -D is_cluster = {true|false}，default false, run with 3 dbles in zookeeper mode
- -D user_debug =  {true|false}，default false, reserve last case environment
 
### behave_dble下的用例按照 allure-behave将用例优先级由高到低分为以下5类:
- BLOCKER
- CRITICAL
- NORMAL
- MINOR
- TRIVIAL

### 基于behave的测试命令集，可通过自定义参数：test_config 选择使用的配置文件
 配置文件可自定义，参考behave_dble/conf/auto_test_dble_release.yaml,这份配置需要将最近发布的dble安装包下载到dble所在主机指定目录/share下。外网用户建议使用该配置而非auto_dble_test.yaml。 使用示例：
>behave -Dreset=false -Dtest_config=auto_test_dble_release.yaml features/install_uninstall/install_dble.feature

### 测试命令集
1. 通过ftp包安装单节点并启动
>behave -Dreset=false -Dtest_config=auto_test_dble_release.yaml features/install_uninstall/install_dble.feature

2. 通过ftp包解压安装dble到所有节点，配置使用zk，启动集群内所有节点(-Dreset=false 参数仅为初始安装dble的必要参数)
>behave -Dreset=false -Dis_cluster=true -Dtest_config=auto_test_dble_release.yaml features/install_uninstall/install_dble_cluster.feature 

3. 通过ftp包解压安装dble到所有节点，配置使用zk，启动所有节点，集群到单节点转换(-Dreset=false 参数仅为初始安装dble的必要参数)
>behave -Dreset=false -Dis_cluster=true features/install_uninstall/single_dble_and_zk_cluster.feature

4. 使用特定配置启动dble
>behave --stop -D dble_conf={sql_cover_sharding | sql_cover_nosharding | sql_cover_global | sql_cover_mixed | template} features/setup.feature

5. 各种表类型的sql覆盖测试
  > * sqls_mixed: 用于默认sql覆盖，包含混合表类型 
  > * sqls_util: 所有表类型的sql覆盖都需要分别覆盖

6. 不适合批量测试的特殊sql语句的测试专项覆盖
>behave -D dble_conf=sql_cover_mixed features/sql_cover/special/

7. 全局表sql测试套件覆盖
>behave -Ddble_conf=sql_cover_global features/sql_cover/sql_global.feature

8. 混合类型表sql测试套件覆盖
>behave -Ddble_conf=sql_cover_mixed features/sql_cover/sql_mixed.feature

9. 分片表sql测试套件覆盖
>behave -Ddble_conf=sql_cover_sharding features/sql_cover/sql_sharding.feature

10. 非分片表sql测试套件覆盖
>behave --stop -Ddble_conf=sql_cover_nosharding features/sql_cover/sql_nosharding.feature

11. 分片算法测试套件覆盖
>behave -D dble_conf=template features/func_test/sharding_func_test/

12. 配置测试套件覆盖
>behave -D dble_conf=template features/func_test/cfg_test/

13. 全局序列功能测试
>behave -D dble_conf=template features/func_test/sequence/sequence.feature

14. 安全性测试套件覆盖
>behave -D dble_conf=template features/func_test/safety/safety.feature

15. 运维命令测试套件覆盖
>behave -D dble_conf=template features/func_test/managercmd/

### zookeeper 使用说明
#### 1.更新dble/conf/myid.properties配置：
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
#### 3.创建并配置myid
在 zoo.cfg配置中dataDir 指定的目录下 (即 /opt/zookeeper/data 目录) 创建名为 myid 的文件, 文件内容和 zoo.cfg 中当前机器的 id 一致，如果正在配置的服务是server.2，则内容为：
```
2
```

#### 4.在集群中的每台机器上执行以下启动命令:"zkServer.sh start", 然后可通过： 'zkServer.sh status' 观察节点状态

### ToImprove list:
####两会话并发交替问题：

1. block确认
2. hang后超时多久连接重建

## 三. 对c_mysql_api中接口的支持度测试
参考：drivers/c_mysql_api下对应文件夹中的README.md

## 四. 对connector/j中接口及sql的支持度测试
参考：drivers/Connector-J下对应文件夹中的README.md

## 五. 对connector/c++中sql的支持度测试
参考：drivers/Connector-cpp下对应文件夹中的README.md

## 六.对connector/.net中sql的支持度测试
参考：drivers/Connector-.net下对应文件夹中的README.md
