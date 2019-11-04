## cluster相关测试
#### behave_dble/features/cluster/check_full_meta_in_cluster.feature
- 集群环境下，主节点执行alter失败时，其他节点的元数据不应该被刷新
- 集群环境下，主节点执行alter成功时，其他节点的元数据应该被同步刷新
#### behave_dble/features/cluster/ddl_in_cluster.feature
- show @@ddl命令大小写不敏感
- 集群中，同库多表执行ddl,show @@ddl能查询到正在执行的所有ddl
- 集群中，不同库同名表执行ddl,show @@ddl能查询到正在执行的所有ddl
- 集群中，可以用指令kill @@ddl_lock where schema=? and table=? kill掉对应的ddl
#### behave_dble/features/cluster/writeHost_support_weight.feature
- 集群中，执行reload @@config_all后，可以同步到正确的"weight"属性
#### behave_dble/features/cluster/xml_version_check.feature
- 使用旧的xml版本时，dryrun及dble.log中有对应的warning信息"The dble-config-version is [0-9].[0-9],but the server.xml version is 9.9.9.0.There must be some incompatible config between two versions, please check it"
- xml版本号格式正确，为想x.y，但版本号错误，dryrun及dble.log中有对应的warning信息"The dble-config-version is [0-9].[0-9],but the server.xml version is 9.9.9.0.There must be some incompatible config between two versions, please check it"
#### behave_dble/features/cluster/zk_sequence.feature
- 检测配置文件sequence_distributed_conf.properties的有效性，包括：INSTANCEID，CLUSTERID，START_TIME(大于dble的启动时间，+17年小于dble的启动时间)值的有效性

## 功能测试
### 配置测试
#### behave_dble/features/func_test/cfg_test/charset.feature
- dble的字符集配置与session字符集配置一致或者不一致时，session字符集优先级高于配置的字符集
- 当客户端的字符集设为utfmb4或者utf8时，对于非ASCII分片列，dble应该路由到相同的数据节点
#### behave_dble/features/func_test/cfg_test/dataNode_caseSensitive.feature
- 数据节点名，不受lower_case_table_names的配置值的影响，都需要保持一致
#### behave_dble/features/func_test/cfg_test/lower_case_table_names.feature
- 后端mysql节点设置为大小写不敏感时，dble处理查询时，大小不写敏感
- 后端mysql节点设置为大小写敏感时，dble处理查询时，大小写敏感
#### behave_dble/features/func_test/cfg_test/navicat.feature
- navicat客户端发送查询语句到mysql 默认数据库时，dble会返回一个假的空结果集
#### behave_dble/features/func_test/cfg_test/rule.feature
- 配置非法的tableRule，执行reload @@config_all命令会失败
- 配置正确hash分片算法，执行reload @@config_all命令成功
- 配置正确的NumberRange分片算法，执行reload @@config_all命令成功
- 配置正确的Enum分片算法，执行reload @@config_all命令成功
#### behave_dble/features/func_test/cfg_test/schema.feature
- 配置er表，且有未用到的dataNode,reload成功
- 只配置dataNode,dble启动失败，只有dataHost,dble启动成功
- 配置文件中含有非法的配置，如<test></test>,reload失败
- dataNode用$配置，reload成功
- readHost/writeHost只配置host属性值，未配置其他属性值，reload失败
- readHost放到writeHost外，reload失败
- 配置未在rule.xml中配置的分片规格，reload失败
- dataNode中配置的数据库未被创建且此dataNode未被任何表使用，dble做ddl时会报错"Unknown database"
- dataNode中配置未数据库未被创建且此dataNode被table使用，dble做ddl时会报错"Unknown database"
- 多个dataNode使用相同的dataHhost中的database,dble启动失败，dry等有报错信息
- dble支持schema名中含有特殊字符"-"
#### behave_dble/features/func_test/cfg_test/schema_attribute.feature
- 针对所有表类型，配置needAddLimit=true，sqlMaxLimit配置有效
- 针对所有表类型，配置needAddLimit=false，sqlMaxLimit配置有效
- table名可配置多个，表名用','隔开
- 测试dataHost中的maxCon属性
- dataHost节点数小于等于相关的dataNode数量，最大连接数为：相关的dataNode+1
#### behave_dble/features/func_test/cfg_test/schema_load_balance.feature
- balance="0"，不做读操作的负载均衡，所有读发到当前激活的writeHost上
- balance="1"，读操作在所有readHost和standby writeHost上均衡
- balance="2"，读操作在所有readHost和writeHost上均衡
- balance="2"，读操作根据weight在所有readHost和writeHost上均衡
- balance="3"，读操作在所有readHost上均衡
- balance="3"，and tempReadHostAvailable="1"，读操作在所有readHost上均衡不管writeHost是否存活
- balance="3"，and tempReadHostAvailable="0"，读操作在所有readHost上均衡不管writeHost是否存活
- balance="2"，一主的weight=1，一从的weight=1，一从的weight=0，读操作在weight=1的一主一从上均衡
- balance="2"，一主的weight=0，读操作不在writeHost上均衡，writeHost只接收写入
#### behave_dble/features/func_test/cfg_test/schema_stable.feature
- 删除非必须的配置（schema，dataNode，dataHost，user等），dble可以启动成功
- dble只配置一个后端mysql时，停止唯一的mysql,reload @@config_all失败，启动mysql后，reload @@config_all成功
- mysql节点配置为disabled="true"，且没有readHost,reload失败
- balance="0"时，且readHost未被使用，reload @@config_all时，dble依然会检查readHost是否可连接，若不能连接，则reload失败
#### behave_dble/features/func_test/cfg_test/server.feature
- 业务用户中添加非法标签，reload @@config_all失败
- 业务用户中加schema.xml中不存在的schema,dble启动失败
- 业务用户配置usingDecrypt=1，启动成功，reload成功，query成功
- server.xml只配置<user>，dble启动成功
- 配置一个或者多个manager用户，reload成功，且可以正确执行管理命令
- 管理用户和业务用户都配置ip白名单，不在白名单中的业务用户执行语句会被拒绝
- 黑名单配置检测
- 用户最大连接数检测（maxCon>0）
- 不配置system中的最大连接数，用户最大连接数检测（maxCon=0）
- 所有用户最大连接数的和大于system中的maxCon数，超出限制则连接失败
- checkTableConsistency=1，checkTableConsistencyPeriod=1000时，修改表结构，dble.log中有对应的warning信息
#### behave_dble/features/func_test/cfg_test/server_privileges.feature
- 已存在的schema和新加的schema配置不同的privileges权限，reload @@config_all成功
- 用户配置readonly,则用户只能在schema的默认节点执行读操作
- 用户配置privilege且check=true：表的显示权限优先级高于schema的权限；各用户的权限互不干扰；表未配置显示的privilege则使用schema的privilege；默认节点的表使用默认权限，或者使用显示配置的privilege；表有不同权限的会join或者union
- check=false时，配置的privileges可正确生效
- 当只配置schema级别的权限时，表的权限继承于schema的权限
#### behave_dble/features/func_test/cfg_test/server_system_value_valid.feature
- 配置<system>中所有的的属性，某些属性配置非法值，dble启动成功（将非法值替换成默认值）
#### behave_dble/features/func_test/cfg_test/view.feature
- view中涉及的table未包含在配置中，reload @@config_all成功，dble启动成功

### 管理命令测试
#### behave_dble/features/func_test/managercmd/check_full_metadata.feature
- 不同的schema中配置相同的table名，dble重启成功，check full @@metadata where schema=? and table=?可以查询处正确的值
- 分片表和非分片表有相同的表名，两表的metadata互不影响
- 全局表和非分片表有相同的表名，两表的metadata互不影响
- schema中未配置表，在默认节点创建一张表（ddl），执行reload @@metadata过程中查看表的metadata
- 后端表metadata不一致或某些数据节点表不存在，检查metadata及查询
- dataHost的某些writeHost(有readHost或者没有readHost)不可连接，检查metadata及查询
- 默认schema的表及分片表含有view在后端节点，检查metadata及查询
- 检查metadata时应该忽略AUTO_INCREMENT的差异，reload @@metadata后dble.log中有相应的ddl日志
- reload @@metadata中添加过滤条件（按schema或者table过滤）
#### behave_dble/features/func_test/managercmd/create_database.feature
- “create database @@...”命令为所有使用的节点创建后端数据库
- “create database @@...”命令为部分使用的节点创建后端数据库
- “create database @@...”命令支持dn$x-y格式
#### behave_dble/features/func_test/managercmd/dryrun.feature
- <table>配置type="default"及type=非法值，dryrun报错
#### behave_dble/features/func_test/managercmd/pause_resume.feature
- pause/resume测试：不带参数的pause；pause带timeout时间不在([0-9]+)内；pause带正确的timeout时间；pause带正确的timeout,queue；pause带正确的timeout,queue，wait_limit；pause不存在的dataNode
- 验证pause中wait_limit条件的正确性
- 在事务执行过程中pause或者事务commit后pause
#### behave_dble/features/func_test/managercmd/reload_config_about_metadata.feature
- reload config时，无需reload所有metadata：如新增表,仅对新增表reload metadata；删除表+表的type属性发生变更;表的datanode发生变更;新增schema;删除schema;schema的默认datanode发生变更
- reload config_all时，无需reload所有metadata：如新增表,仅对新增表reload metadata；删除表+表的type属性发生变更;表的物理节点发生变更;表的datasource发生变更;新增schema;删除schema;schema的默认datanode发生变更;schema的datanode对应的物理节点发生变更;schema对应的Datanode对应的DataSource发生变更
#### behave_dble/features/func_test/managercmd/reload_config_all.feature
- writeHost未变更，reload @@config_all不会重建后端连接池
- 移除旧的writeHost再创建新的writeHost，reload @@config_all会关闭旧的writeHost所持有的后端连接池，创建新的连接池，在使用中的连接池不会被关闭：reload @@config_all -f, reload @@config_all -r, reload @@config_all -s，后端使用中的连接不会关闭尽管writeHost被移除；reload @@config_all -f，会杀掉使用中的后端连接，且进行diff；reload @@config_all -r，不会进行diff,跳过使用中的后端连接，重建后端连接；reload @@config_all -s，跳过测试新的连接
#### behave_dble/features/func_test/managercmd/show_binlog_status.feature
- 物理库均未被创建，show @@binlog.status可以执行成功
- behave_dble/features/func_test/managercmd/show_connection.feature
- sql语句执行时间小于1ms时，show @@connection.sql能查询到此语句
- sql语句执行时间大于1ms时，show @@connection.sql能查询到此语句
- 多个事务，多个查询，show @@connection.sql能查询到此语句
#### behave_dble/features/func_test/managercmd/show_datasource.feature
- show @@datasource的ACTIVE列不能为负数
- show @@datasource的ACTIVE列值正确
#### behave_dble/features/func_test/managercmd/show_processlist.feature
- show @@processlist命令查看前后段连接的session
#### behave_dble/features/func_test/managercmd/show_sqlX.feature
- show @@sql命令可查询出CRUD语句，show @@sql.resultset可以过滤出比maxResultSet值大的语句
#### behave_dble/features/func_test/managercmd/show_user.feature
- show @@user命令可以查询出配置的user信息，show @@user.privilege可以查询出各user的相关权限
#### behave_dble/features/func_test/managercmd/slow_query.feature
- 测试enable @@slow_query_log，disable @@slow_query_log，show @@slow_query_log
- 测试show @@slow_query.time，reload @@slow_query.time，show @@slow_query.flushperid，reload @@slow_query.flushperid，show @@slow_query.flushsize，reload @@slow_query.flushsize
- 测试slow log可以写到指定的文件中
- 功能测试——>meta锁
#### behave_dble/features/func_test/metalock/ddl_meta_lock.feature
- 执行select 1语句阶段客户端断开，dble会释放ddl元数据锁

### 安全性测试
#### behave_dble/features/func_test/safety/cross_db_sql.feature
- 未配置默认数据库，垮裤表相互不影响，且执行查询结果正确
#### behave_dble/features/func_test/safety/mysql_node_disconnected.feature
- 只有一个后端mysql节点，且此mysql节点不能连接，则dryrun及reload @@config_all提示节点不可连接的信息,dble.log中记录相关失败信息
- 有多个后端mysql节点，部分节点不可连接，dryrun和reload @@config_all提示节点不可连接的信息，dble重启成功
- 有多个后端mysql节点，在事务中，部分节点不可连接
- 事务中发送sql到未创建的物理库中，dble返回报错
#### behave_dble/features/func_test/safety/safety.feature
- 多租户模式下，验证租户的权限正确
- 语句中包含2个子查询时，引起线程安全问题

### 全局序列测试
#### behave_dble/features/func_test/sequence/sequence.feature
- 全局序列MySQL-offset-step类型：不能对全局序列字段显示插入值；序列值必须唯一；单线程插入值到全局序列列，则生成的序列值应该保持连续；多线程插入值到全局序列列，序列值需唯一，插入时间应该小于1s
- 全局序列snowflake类型：不能对全局序列字段显示插入值；序列值必须唯一；多线程插入值到全局序列列，序列值需唯一；全局序列须为bigint类型
- 验证配置文件sequence_time_conf.properties中配置非法值：WORKID的取值范围需在01~31之间；DATAACENTERID的取值范围需在01~15之间；START_TIME>dble的启动时间；START_TIME+69年<dble的启动时间

### 分片算法测试
#### behave_dble/features/func_test/sharding_func_test/date.feature
- 未配置sBeginDate,reload @@config_all失败
- sBeginDate < sEndDate-nodes*sPartition+1，reload @@config_all提示信息"please make sure table datanode size = function partition size"
- 配置sBeginDate和默认节点，reload @@config_all成功后，允许插入null字段插入null值，路由到默认节点；非NULL字段中插入NULL值，则返回报错"Sharding column can't be null when the table in MySQL column is not null"
- 配置sEndDate且未配置默认节点，reload @@config_all后，插入的值小于sBeginDate配置的值，则返回报错"can't find any valid data node"
- 未配置sEndDate且配置defaultNode，reload @@config_all后，当插入值大于sBeginDate且插入值>sum(sBeginDate +sPartionDay*dataNode),则返回报错信息"can't find any valid data node"
- 未配置sEndDate且未配置defaultNode:reload可以成功，当插入值小于sBeginDate时，返回报错信息"can't find any valid data node";当插入值大于sBeginDate且插入值>sum(sBeginDate +sPartionDay*dataNode),则返回报错信息"can't find any valid data node"
- 分片表的使用限制：
分片表的分片列不能drop；
分片表的分片列值不允许被更新；
分片表插入值时，分片列必须显示插入值；
分片表插入值时，插入的分片列值不支持表达式的形式；
创建的分片表示不包含分片列，则插入报错；
- 分片列的数据类型支持度测试：
分片列的数据类型为date类型；
分片列的数据类型为time类型；
分片列的数据类型为timestamp类型；
分片列的数据类型为datetime类型；
分片列的数据类型为year4类型；
#### behave_dble/features/func_test/sharding_func_test/enum.feature
- type=0（即配置成integer类型），且未配置默认节点:若插入的int类型的值不在配置文件中，则返回报错信息"can't find any valid data node";若插入值为字符类型，则返回报错"Please check if the format satisfied"
- type！=0（即配置成string类型），且配置默认节点:插入数值或字符串成功
- 分片表的使用限制：
分片表的分片列不能drop；
分片表的分片列值不允许被更新；
分片表插入值时，分片列必须显示插入值；
分片表插入值时，插入的分片列值不支持表达式的形式；
创建的分片表示不包含分片列，则插入报错；
- 分片列的数据类型支持度测试：
int,varchar,int(5) ZEROFILL,int ZEROFILL,int(5) UNSIGNED ZEROFILL,int UNSIGNED ZEROFILL,INTEGER,INTEGER(5),INTEGER(5) ZEROFILL,INTEGER ZEROFILL,INTEGER(5) UNSIGNED ZEROFILL,INTEGER UNSIGNED ZEROFILL,tinyint,tinyint(2),tinyint(3) ZEROFILL,tinyint ZEROFILL,tinyint(3) UNSIGNED ZEROFILL,tinyint UNSIGNED ZEROFILL,smallint,smallint(3),smallint(6) ZEROFILL,smallint ZEROFILL,smallint(6) UNSIGNED ZEROFILL,smallint UNSIGNED ZEROFILL,mediumint,mediumint(5),mediumint(6) ZEROFILL,mediumint ZEROFILL,mediumint(6) UNSIGNED ZEROFILL,mediumint UNSIGNED ZEROFILL,char,char(5),char(255),varchar(0),varchar(30),binary,binary(5),varbinary(5),tinyblob,blob,mediumblob,longblob,tinytext,tinytext binary,text,text binary,mediumtext,longtext,longtext binary
#### behave_dble/features/func_test/sharding_func_test/hash.feature
- Sum(count[i]*length[i]) >=2880时，reload @@config_all报错
- 测试每个分片包含的值为均匀分布的情况
- 测试每个分片包含的值为非均匀分布的情况
- 分片表的使用限制：
分片表的分片列不能drop；
分片表的分片列值不允许被更新；
分片表插入值时，分片列必须显示插入值；
分片表插入值时，插入的分片列值不支持表达式的形式；
创建的分片表示不包含分片列，则插入报错；
- 分片列的数据类型支持度测试：
bit(5),bit(8),bit(16),bit(24),bit(29),bit(32),bit(40),bit(48),bit(56),bit(59),bit(64),tinyint,tinyint(2),tinyint UNSIGNED,tinyint(2) UNSIGNED,tinyint(3) ZEROFILL,tinyint ZEROFILL,tinyint(3) UNSIGNED ZEROFILL,tinyint UNSIGNED ZEROFILL,smallint,smallint(3),smallint(6) ZEROFILL,smallint ZEROFILL,smallint UNSIGNED,smallint(3) UNSIGNED,smallint(6) UNSIGNED ZEROFILL,smallint UNSIGNED ZEROFILL,mediumint,mediumint(5),mediumint(6) ZEROFILL,mediumint ZEROFILL,mediumint UNSIGNED,mediumint(5) UNSIGNED,mediumint(6) UNSIGNED ZEROFILL,mediumint UNSIGNED ZEROFILL,int,int UNSIGNED,int(11) UNSIGNED,int(5) ZEROFILL,int ZEROFILL,int(5) UNSIGNED ZEROFILL,int UNSIGNED ZEROFILL,INTEGER,INTEGER(5),INTEGER UNSIGNED,INTEGER(5) UNSIGNED,INTEGER(5) ZEROFILL,INTEGER ZEROFILL,INTEGER(5) UNSIGNED ZEROFILL,INTEGER UNSIGNED ZEROFILL,bigint,bigint(3),bigint(6) ZEROFILL,bigint ZEROFILL,decimal(10,2),numeric(10,2),float(7,4),double(7,4),enum('1','2','3','4','5'),enum('a','b','c','d','f'),varchar(10)
#### behave_dble/features/func_test/sharding_func_test/jumpstringhash.feature
- mysql中字段值为允许null，则插入null值时恒定落在0号节点上
- 分片表的使用限制：
分片表的分片列不能drop；
分片表的分片列值不允许被更新；
分片表插入值时，分片列必须显示插入值；
分片表插入值时，插入的分片列值不支持表达式的形式；
创建的分片表示不包含分片列，则插入报错；
#### behave_dble/features/func_test/sharding_func_test/numberrange.feature
- 配置了默认节点：则null落在默认节点（若字段值不能为NULL值则返回报错），不在配置中的值落在默认节点，其他则按配置落在对应的节点上
- 未配置默认节点：插入值为NULL或不在配置中，则返回报错"can't find any valid data node"
- 分片表的使用限制：
分片表的分片列不能drop；
分片表的分片列值不允许被更新；
分片表插入值时，分片列必须显示插入值；
分片表插入值时，插入的分片列值不支持表达式的形式；
创建的分片表示不包含分片列，则插入报错；
- 分片列的数据类型支持度测试：
bit(5),bit(8),bit(16),bit(24),bit(29),bit(32),bit(40),bit(48),bit(56),bit(59),bit(64),tinyint,tinyint(2),tinyint UNSIGNED,tinyint(2) UNSIGNED,tinyint(3) ZEROFILL,tinyint ZEROFILL,tinyint(3) UNSIGNED ZEROFILL,tinyint UNSIGNED ZEROFILL,smallint,smallint(3),smallint(6) ZEROFILL,smallint ZEROFILL,smallint UNSIGNED,smallint(3) UNSIGNED,smallint(6) UNSIGNED ZEROFILL,smallint UNSIGNED ZEROFILL,mediumint,mediumint(5),mediumint(6) ZEROFILL,mediumint ZEROFILL,mediumint UNSIGNED,mediumint(5) UNSIGNED,mediumint(6) UNSIGNED ZEROFILL,mediumint UNSIGNED ZEROFILL,int,int UNSIGNED,int(11) UNSIGNED,int(5) ZEROFILL,int ZEROFILL,int(5) UNSIGNED ZEROFILL,int UNSIGNED ZEROFILL,INTEGER,INTEGER(5),INTEGER UNSIGNED,INTEGER(5) UNSIGNED,INTEGER(5) ZEROFILL,INTEGER ZEROFILL,INTEGER(5) UNSIGNED ZEROFILL,INTEGER UNSIGNED ZEROFILL,bigint,bigint(3),bigint(6) ZEROFILL,bigint ZEROFILL,decimal(10,2),numeric(10,2),float(7,4),double(7,4),enum('1','2','3','4','5'),enum('a','b','c','d','f')
#### behave_dble/features/func_test/sharding_func_test/patternrange.feature
- 配置了默认节点：则null落在默认节点（若字段值不能为NULL值则返回报错），不在配置中的值落在默认节点，其他则按配置落在对应的节点上
- 未配置默认节点：插入值为NULL或不在配置中，则返回报错"can't find any valid data node"
- 分片表的使用限制：
分片表的分片列不能drop；
分片表的分片列值不允许被更新；
分片表插入值时，分片列必须显示插入值；
分片表插入值时，插入的分片列值不支持表达式的形式；
创建的分片表示不包含分片列，则插入报错；
- 分片列的数据类型支持度测试：
bit(5),bit(8),bit(16),bit(24),bit(29),bit(32),bit(40),bit(48),bit(56),bit(59),bit(64),tinyint,tinyint(2),tinyint UNSIGNED,tinyint(2) UNSIGNED,tinyint(3) ZEROFILL,tinyint ZEROFILL,tinyint(3) UNSIGNED ZEROFILL,tinyint UNSIGNED ZEROFILL,smallint,smallint(3),smallint(6) ZEROFILL,smallint ZEROFILL,smallint UNSIGNED,smallint(3) UNSIGNED,smallint(6) UNSIGNED ZEROFILL,smallint UNSIGNED ZEROFILL,mediumint,mediumint(5),mediumint(6) ZEROFILL,mediumint ZEROFILL,mediumint UNSIGNED,mediumint(5) UNSIGNED,mediumint(6) UNSIGNED ZEROFILL,mediumint UNSIGNED ZEROFILL,int,int UNSIGNED,int(11) UNSIGNED,int(5) ZEROFILL,int ZEROFILL,int(5) UNSIGNED ZEROFILL,int UNSIGNED ZEROFILL,INTEGER,INTEGER(5),INTEGER UNSIGNED,INTEGER(5) UNSIGNED,INTEGER(5) ZEROFILL,INTEGER ZEROFILL,INTEGER(5) UNSIGNED ZEROFILL,INTEGER UNSIGNED ZEROFILL,bigint,bigint(3),bigint(6) ZEROFILL,bigint ZEROFILL,decimal(10,2),numeric(10,2),float(7,4),double(7,4),enum('1','2','3','4','5'),enum('a','b','c','d','f')
#### behave_dble/features/func_test/sharding_func_test/stringhash.feature
- Sum(count[i]*length[i])>=2880时，reload @@config_all返回报错"Sum(count[i]*length[i]) must be less than 2880"
- 测试每个分片包含的值为均匀分布的情况
- 测试每个分片包含的值为非均匀分布的情况
- 分片表的使用限制：
分片表的分片列不能drop；
分片表的分片列值不允许被更新；
分片表插入值时，分片列必须显示插入值；
分片表插入值时，插入的分片列值不支持表达式的形式；
创建的分片表示不包含分片列，则插入报错；

## 安装卸载测试（包括单机及zk集群）
#### behave_dble/features/install_uninstall/install_dble.feature
- 在一个干净的环境中安装dble并启动
#### behave_dble/features/install_uninstall/install_dble_cluster.feature
- 安装zk集群，安装dble集群（包含3个dble），配置并启动集群
#### behave_dble/features/install_uninstall/single_dble_and_zk_cluster.feature
- 安装zk集群,退化成单dble，然后再恢复zk集群
- 配置3个dble到集群，则配置的dble都在线，停止其中一台dble服务，则停止的dble退出集群
- 配置3台dble到zk集群，再重启dble-1，则dble-1中配置文件dnindex.properties包含"localhost1=0"
#### behave_dble/features/install_uninstall/stop_dble_cluster.feature
- 停止dble集群及zk服务

## sql覆盖测试
### 特殊sql
#### behave_dble/features/sql_cover/special/chinese_comment.feature
- wrapper.conf中配置”-Dfile.encoding=GBK“，且server.xml中配置charset=utf8mb4,则插入中文comment配置成功
#### behave_dble/features/sql_cover/special/error_message.feature
- union不同的列数，dble返回报错
- 非期望的explain（如：explain explain select 1）返回结果测试：返回报错”Inner command not route to MySQL: ***“
- select中包含关联子查询会抛出错误”Correlated Sub Queries is not supported“
- 当物理库未创建时，在xa事务中执行语句会报错”Unknown database 'db3'“
#### behave_dble/features/sql_cover/special/hint.feature
- 验证hint格式为：/*!dble:datanode=xxx*/
- 验证hint格式为：/*!dble:sql=xxx*/
- 验证hint格式为：/*!dble:db_type=xxx*/且balance=1的情况
#### behave_dble/features/sql_cover/special/loaddata.feature
- maxCharsPerColumn为默认值时，单列字符长度为68888时，loaddata导入时返回报错”error totally whack“
- maxCharsPerColumn参数值<68888，导入的单列字符长度为68888时返回报错”error totally whack“
- maxCharsPerColumn参数值>=68888，导入的单列字符长度为68888时导入成功
- 导入的行以”#“开始，loaddata导入成功，”#“插入到第一列中
- laoddata导入全局序列（sequnceHandlerType=2）成功
- 导入的值包含””“，loaddata导入成功
- 导入的数据值中含有tab,loaddata导入成功
#### behave_dble/features/sql_cover/special/manager.feature
- 管理命令测试
#### behave_dble/features/sql_cover/special/show_table_type.feature
- show full tables命令返回的表类型为“BASE TABLE”
#### behave_dble/features/sql_cover/special/show_trace.feature
- 两表join时，join右边的表含有大量数据，show trace能返回正确的结果
#### behave_dble/features/sql_cover/special/sql_transformation.feature
- explain结果中limit的验证
#### behave_dble/features/sql_cover/special/subquery_plan_optimize.feature
- ER表，包含子查询的执行计划的优化
- 全句表，包含子查询的执行计划的优化
- 执行计划中merge部分的优化
#### behave_dble/features/sql_cover/special/xa_transaction.feature
- xa事务中的复杂查询执行成功
### 全局表
### 混合表
### 非分片表
### 分片表

## driver相关测试
### 多语句测试
### C-MySQL-API测试
### .net connectors的sql支持度
### cpp connector的sql支持度
### java connector的sql支持度
### jdbc-api测试