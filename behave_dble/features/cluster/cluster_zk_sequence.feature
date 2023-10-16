# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangjiaoge at 2023/10/13

Feature: zk-mode

    Scenario: zk-mode
     """
        testlink:dble-11009
     
     """
        Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-1" with sed cmds
        """
        /sequenceHandlerType/d
        $a sequenceHandlerType=4
        """
        Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-2" with sed cmds
        """
        /sequenceHandlerType/d
        $a sequenceHandlerType=4
        """
        Given update file content "{install_dir}/dble/conf/cluster.cnf" in "dble-3" with sed cmds
        """
        /sequenceHandlerType/d
        $a sequenceHandlerType=4
        """
        Given Restart dble in "dble-1" success
        Given Restart dble in "dble-2" success
        Given Restart dble in "dble-3" success
        Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
        """
        <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
            <shardingTable name="table1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" incrementColumn="inc"/>
            <shardingTable name="Table2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" incrementColumn="inc"/>
        </schema>
        """
        #1
        When Add some data in "sequence_conf.properties"
        """
        `schema1`.`table1`.MINID=1001
        `schema1`.`table1`.MAXID=2000
        `schema1`.`table1`.CURID=1000
        `schema2`.`Table2`.MINID=1001
        `schema2`.`Table2`.MAXID=20000
        `schema2`.`Table2`.CURID=1000
        """
        Then execute admin cmd "reload @@config_all"
        Then execute sql in "dble-1" in "user" mode
            | conn   | toClose | sql                                                                                      | expect            | db      |
            | conn_0 | False   | drop table if exists Table2                                                              | success           | schema1 |
            | conn_0 | False   | drop table if exists table1                                                              | success           | schema1 |
            | conn_0 | False   | create table table1(id int,inc int,k int unsigned not null default '0',primary key(id)); | success           | schema1 |
            | conn_0 | False   | create table Table2(id int,inc int,k int unsigned not null default '0',primary key(id)); | success           | schema1 |
            | conn_0 | False   | insert into table1 values(1,1) ;                                                         | success           | schema1 |
            | conn_0 | False   | select * from table1;                                                                    | success           | schema1 |
            | conn_0 | False   | insert into Table2 values(1,1) ;                                                         | can't find definition for sequence :`schema1`.`Table2`  | schema1 |
        When Add some data in "sequence_conf.properties"
        """
        `schema1`.`table1`.MINID=1001
        `schema1`.`table1`.MAXID=2000
        `schema1`.`table1`.CURID=1000
        `schema1`.`Table2`.MINID=1001
        `schema1`.`Table2`.MAXID=20000
        `schema1`.`Table2`.CURID=1000
        """
        Then execute admin cmd "reload @@config_all"
        Then execute sql in "dble-1" in "user" mode
            | conn   | toClose | sql                                                 | expect   | db      | 
            | conn_0 | False   | insert into Table2 values(1,1) ;                    | success  | schema1 |
            | conn_0 | False   | select * from Table2;                               | success  | schema1 |
        #2 dry-run不加载变动的sequence.properties
        When Add some data in "sequence_conf.properties"
        """
        """
        Then execute admin cmd "dryrun"
        Then execute sql in "dble-1" in "user" mode
            | conn   | toClose | sql                                                 | expect   | db      |
            | conn_0 | False   | insert into table1 values(2,2) ;                    | success  | schema1 |
            | conn_0 | False   | select * from table1;                               | success  | schema1 |
            | conn_0 | False   | insert into Table2 values(2,2) ;                    | success  | schema1 |
            | conn_0 | False   | select * from Table2;                               | success  | schema1 |
        #3
        Then execute admin cmd "reload @@config_all"
        Then execute sql in "dble-1" in "user" mode
            | conn   | toClose | sql                                      | expect            | db      |
            | conn_0 | False   | insert into Table2 values(3,3) ;         | can't find definition for sequence :`schema1`.`Table2`  | schema1 |
            | conn_0 | False   | select * from Table2;                    | success  | schema1 |
            | conn_0 | False   | insert into table1 values(3,3) ;         | can't find definition for sequence :`schema1`.`table1`  | schema1 |
            | conn_0 | False   | select * from table1;                    | success  | schema1 |
        #4
        When Add some data in "sequence_conf.properties"
        """
        `schema1`.`table1`.MINID=1001
        `schema1`.`table1`.MAXID=2000
        `schema1`.`table1`.CURID=1000
        `schema1`.`Table2`.MINID=1001
        `schema1`.`Table2`.MAXID=20000
        `schema1`.`Table2`.CURID=1000
        """
        Then execute admin cmd "reload @@config_all"
        Then execute sql in "dble-1" in "user" mode
            | conn   | toClose | sql                                    | expect   | db      |
            | conn_0 | False   | insert into Table2 values(3,3) ;       | success  | schema1 |
            | conn_0 | False   | select * from Table2;                  | success  | schema1 |
            | conn_0 | False   | insert into table1 values(3,3) ;       | success  | schema1 |
            | conn_0 | False   | select * from table1;                  | success  | schema1 |