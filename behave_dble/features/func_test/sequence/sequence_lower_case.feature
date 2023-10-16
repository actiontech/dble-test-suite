# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangjiaoge at 2023/10/13

Feature: single-mode
    @restore_mysql_config
    Scenario: issues
        """
        {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0},'mysql-master2':{'lower_case_table_names':0}}}
        """
        #1.disable-enable    
        # 初始disable dbgroups ，9066执行enable后，insert和select正常
        Given restart mysql in "mysql-master1" with sed cmds to update mysql config
        """
        /lower_case_table_names/d
        /server-id/a lower_case_table_names = 1
        """
        Given restart mysql in "mysql-master2" with sed cmds to update mysql config
         """
         /lower_case_table_names/d
         /server-id/a lower_case_table_names = 1
         """
        Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
            """
            <shardingTable name="test_auto" shardingNode="dn1,dn2,dn3,dn4" incrementColumn="id" shardingColumn="id" function="hash-four" />
            """
        Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
            """
            <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
            <heartbeat>select user()</heartbeat>
            <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
            </dbInstance>
            </dbGroup>

            <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
            <heartbeat>select user()</heartbeat>
            <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
            </dbInstance>
            </dbGroup>
            """
        Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
            """
            $a sequenceHandlerType=1
            """
        When Add some data in "sequence_db_conf.properties"
            """
            `schema1`.`test_auto`=dn1
            """
        #以下因为issue-2167，先设置lower_case_table_name是1然后替换文件中的大小写后初始化mysql中的dble_sequence
        Given update file content "/opt/dble/conf/dbseq.sql" in "dble-1" with sed cmds
            """
            s/DBLE_SEQUENCE/dble_sequence/
            """
        Then initialize mysql-off-step sequence table
        Given restart mysql in "mysql-master1" with sed cmds to update mysql config
        """
        /lower_case_table_names/d
        /server-id/a lower_case_table_names = 0
        """
        Given restart mysql in "mysql-master2" with sed cmds to update mysql config
         """
         /lower_case_table_names/d
         /server-id/a lower_case_table_names = 0
         """
        Given Restart dble in "dble-1" success
        Given restart mysql in "mysql-master1" with sed cmds to update mysql config
        """
        /lower_case_table_names/d
        /server-id/a lower_case_table_names = 1
        """
        Given restart mysql in "mysql-master2" with sed cmds to update mysql config
         """
         /lower_case_table_names/d
         /server-id/a lower_case_table_names = 1
         """
        Then execute sql in "dble-1" in "admin" mode
            | conn   | toClose   | sql                               | expect  |
            | conn_1 | False     | dbGroup @@enable name='ha_group1' | success |
            | conn_1 | False     | dbGroup @@enable name='ha_group2' | success |

        Then execute sql in "dble-1" in "user" mode
            | conn   | toClose | sql                                                                            | expect            | db      |
            | conn_0 | False   | drop table if exists test_auto                                                 | success           | schema1 |
            | conn_0 | False   | create table test_auto(id bigint primary key auto_increment, v int)            | success           | schema1 |
            | conn_0 | False   | insert into test_auto values(1)                                                | success           | schema1 |
            | conn_0 | False   | insert into TEST_AUTO values(2)                                                | success           | schema1 |
            | conn_0 | False   | select * from test_auto                                                        | success           | schema1 |
            | conn_0 | False   | select * from TEST_AUTO                                                        | success           | schema1 |
    #  issue DBLE0REQ-2161
    #  dry-run不加载变动的sequence.properties
        When Add some data in "sequence_db_conf.properties"
            """
            """
        Then execute admin cmd "dryrun"
        Then execute sql in "dble-1" in "user" mode
            | conn   | toClose | sql                                                                         | expect            | db      |
            | conn_0 | False   | insert into TEST_AUTO values(3)                                             | success           | schema1 |
            | conn_0 | False   | select * from test_auto                                                     | success           | schema1 |
        When Add some data in "sequence_db_conf.properties"
            """
            `schema1`.`test_auto`=dn1
            """
    #  issue DBLE0REQ-2193
    #  dryrun检测sequence_db_conf.properties配置时，当shardingNode不存在时，需要提示
        When Add some data in "sequence_db_conf.properties"
            """
            `schema1`.`test_auto`=dn9
            """
        #dn9在表中不存在
        Given execute single sql in "dble-1" in "admin" mode and save resultset in "dryrun_rs"
            | sql    |
            | dryrun |
        Then check resultset "dryrun_rs" has lines with following column values
            | TYPE-0  | LEVEL-1 | DETAIL-2                                          |
            | Xml     | ERROR   | get variables exception: the shardingNodes[dn9] of the sequence_db_conf.properties in sharding.xml does not exist |
            | Cluster | NOTICE  | Dble is in single mod                             |
        Then restart dble in "dble-1" failed for
            """
            the shardingNodes\[dn9\] of the sequence_db_conf.properties in sharding.xml does not exist
            """
        When Add some data in "sequence_db_conf.properties"
            """
            `schema1`.`test_auto`=dn1
            """