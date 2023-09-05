# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/10/27

Feature: check dbDistrict and dbDataCenter

  Scenario: check dbDistrict and dbDataCenter value #1
    # check default value
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                        | db               | expect      |
      | conn_0 | false   | select variable_name, variable_value from dble_variables where variable_name in ('district', 'dataCenter') | dble_information | has{(('district','null'), ('dataCenter','null'),)} |
      | conn_0 | true    | select db_district,db_data_center from dble_db_instance where db_district!='' or db_data_center !=''       | dble_information | length{(0)} |

    # reload: check db.xml null value
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: property [ dbDistrict ]  is illegal, the value not be empty
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDataCenter="" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: property [ dbDataCenter ]  is illegal, the value not be empty
    """

    # reload: check db.xml special character
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="abc@123" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: properties of system may not recognized:abc@123the UTF-8 encoding is recommended, dbInstance name dbDistrict show be use  u4E00-u9FA5a-zA-Z_0-9\-\.
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDataCenter="def%456" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: properties of system may not recognized:def%456the UTF-8 encoding is recommended, dbInstance name dbDataCenter show be use  u4E00-u9FA5a-zA-Z_0-9\-\.
    """

    # reload: check db.xml alphabet and digit
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="abc" dbDataCenter="123" />
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="ABC_123" dbDataCenter="Def-456" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                          | db               | expect      |
      | conn_0 | true    | select name,db_district,db_data_center from dble_db_instance | dble_information | has{(('hostM1','abc','123'),('hostM2','ABC_123','Def-456'))} |

    # restart: check db.xml null value
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="" />
    </dbGroup>
    """
    Then restart dble in "dble-1" failed for
    """
    com.actiontech.dble.config.util.ConfigException: property \[ dbDistrict \]  is illegal, the value not be empty
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDataCenter="" />
    </dbGroup>
    """
    Then restart dble in "dble-1" failed for
    """
    com.actiontech.dble.config.util.ConfigException: property \[ dbDataCenter \]  is illegal, the value not be empty
    """

    # restart: check db.xml special character
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="abc@123" />
    </dbGroup>
    """
    Then restart dble in "dble-1" failed for
    """
    properties of system may not recognized:abc@123the UTF-8 encoding is recommended, dbInstance name dbDistrict show be use  u4E00-u9FA5a-zA-Z_0-9\\\-\\\.
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDataCenter="def%456" />
    </dbGroup>
    """
    Then restart dble in "dble-1" failed for
    """
    properties of system may not recognized:def%456the UTF-8 encoding is recommended, dbInstance name dbDataCenter show be use  u4E00-u9FA5a-zA-Z_0-9\\\-\\\.
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" />
    </dbGroup>
    """

    # restart: check bootstrap.cnf null value
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict/d
    $a -Ddistrict=
    /-DdataCenter/d
    $a -DdataCenter=
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ dataCenter \]  in bootstrap.cnf is illegal, Property \[ dataCenter \]  not be null or empty
    Property \[ district \]  in bootstrap.cnf is illegal, Property \[ district \]  not be null or empty
    """

    # restart: check bootstrap.cnf special character
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DdataCenter/d
    /-Ddistrict/d
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -Ddistrict=123@abc
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ district \] 123@abc in bootstrap.cnf is illegal,the UTF-8 encoding is recommended, Property \[ district \]  show be use  u4E00-u9FA5a-zA-Z_0-9\\\-\\\.
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DdataCenter=456+def
    /-Ddistrict/d
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ dataCenter \] 456+def in bootstrap.cnf is illegal,the UTF-8 encoding is recommended, Property \[ dataCenter \]  show be use  u4E00-u9FA5a-zA-Z_0-9\\\-\\\.
    """

    # restart: check bootstrap.cnf alphabet value
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -Ddistrict=Shanghai
    /-DdataCenter=/c -DdataCenter=Xuhui
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                        | db               | expect      |
      | conn_0 | true    | select variable_name, variable_value from dble_variables where variable_name in ('district', 'dataCenter') | dble_information | has{(('district','Shanghai'), ('dataCenter','Xuhui'),)}  |

     # restart : check bootstrap.cnf digit value
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict=/c -Ddistrict=123
    /-DdataCenter=/c -DdataCenter=456
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                        | db               | expect      |
      | conn_0 | true    | select variable_name, variable_value from dble_variables where variable_name in ('district', 'dataCenter') | dble_information | has{(('district','123'), ('dataCenter','456'),)}  |

    # restart: check bootstrap.cnf include alphabet and digit
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict=/c -Ddistrict=Ab_12-c
    /-DdataCenter=/c -DdataCenter=dE-34_F
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                       | db               | expect      |
      | conn_0 | true    | select variable_name,variable_value from dble_variables where variable_name in ('district', 'dataCenter') | dble_information | has{(('district','Ab_12-c'), ('dataCenter','dE-34_F'),)} |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                               | db              | expect         |
      | conn_0 | true    | insert into dble_db_group(name,heartbeat_stmt,heartbeat_timeout,heartbeat_retry,rw_split_mode,delay_threshold,disable_ha) value ('ha_group3','select 1',0,1,0,100,'false') | dble_information | success |
      | conn_0 | true    | insert into dble_db_instance(name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count,db_district,db_data_center) value ('hostM3','ha_group3','172.100.9.4','3306','test','111111','false','true','3','100','Ab_12-c','dE-34_F') | dble_information | success |
      | conn_0 | true    | select name,db_district,db_data_center from dble_db_instance where name='hostM3'                  | dble_information | has{(('hostM3','Ab_12-c','dE-34_F'),)} |
      | conn_0 | true    | update dble_db_instance set db_district='Xuhui',db_data_center='Shanghai' where name='hostM3'     | dble_information | success |
      | conn_0 | true    | select name,db_district,db_data_center from dble_db_instance where name='hostM3'                  | dble_information | has{(('hostM3','Xuhui','Shanghai'),)} |
      | conn_0 | true    | delete from dble_db_instance where name='hostM3'                                                  | dble_information | success |
      | conn_0 | true    | select name,db_district,db_data_center from dble_db_instance where name='hostM3'                  | dble_information | length{(0)} |

  @skip
  Scenario: check Chinese value #2
    # restart: check db.xml Chinese character
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="上海abc" dbDataCenter="徐汇123" />
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="浙江_Ab-12" dbDataCenter="杭州-cD_34" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                          | db               | expect      |
      | conn_0 | true    | select name,db_district,db_data_center from dble_db_instance | dble_information | has{(('hostM1','上海abc','徐汇123'),('hostM2','浙江_Ab-12','杭州-cD_34'))} |

    # restart: check bootstrap.cnf Chinese character
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict/d
    $a -Ddistrict=上海_Ab-12
    /-DdataCenter/d
    $a -DdataCenter=徐汇-cD_34
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="上海abc" dbDataCenter="徐汇123" />
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="浙江_Ab-12" dbDataCenter="杭州-cD_34" />
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                        | db               | expect      | charset |
      | conn_0 | true    | select variable_name, variable_value from dble_variables where variable_name in ('district', 'dataCenter') | dble_information | has{(('district','上海_Ab-12'), ('dataCenter','徐汇-cD_34'),)} | utf8mb4 |