# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2023/08/16


  @skip
Feature: test enableCheckSchema in bootstrap.cnf - DBLE0REQ-2060
    #about http://10.186.18.11/jira/browse/DBLE0REQ-2060  just for  3.21.03


  Scenario: check enableCheckSchema values    #1
    ##默认值
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                          | expect                                                                                                 | db               |
      | conn_0 | true    | select * from dble_variables where variable_name = 'enableCheckSchema'       | has{(('enableCheckSchema', '1', 'Whether enable check schema, default value is 1(on)', 'true'),)}      | dble_information |

    ## 非法值测试
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DenableCheckSchema=99.99
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableCheckSchema \] '99.99' data type should be int
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableCheckSchema=99.99/-DenableCheckSchema=-199/
      """
    Then restart dble in "dble-1" failed for
      """
      Property \[ enableCheckSchema \] '-199' in bootstrap.cnf is illegal, you may need use the default value 1 replaced
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableCheckSchema=-199/-DenableCheckSchema=abc/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableCheckSchema \] 'abc' data type should be int
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableCheckSchema=abc/-DenableCheckSchema=null/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableCheckSchema \] 'null' data type should be int
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableCheckSchema=null/-DenableCheckSchema=/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableCheckSchema \] '' data type should be int
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableCheckSchema=/-DenableCheckSchema=@/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableCheckSchema \] '@' data type should be int
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableCheckSchema=@/-DenableCheckSchema=true/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableCheckSchema \] 'true' data type should be int
      """

    ### 值为1和值为0 可以启动成功
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableCheckSchema=true/-DenableCheckSchema=1/
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                          | expect                                                                                                 | db               |
      | conn_0 | true    | select * from dble_variables where variable_name = 'enableCheckSchema'       | has{(('enableCheckSchema', '1', 'Whether enable check schema, default value is 1(on)', 'true'),)}      | dble_information |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableCheckSchema=1/-DenableCheckSchema=0/
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                          | expect                                                                                                 | db               |
      | conn_0 | true    | select * from dble_variables where variable_name = 'enableCheckSchema'       | has{(('enableCheckSchema', '0', 'Whether enable check schema, default value is 1(on)', 'true'),)}      | dble_information |


  Scenario: check enableCheckSchema=1     #2

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
      """
    Then execute admin cmd "reload @@config_all"

#### rwSplitUser
    Given execute linux command in "dble-1"
      """
      mysql -P{node:client_port} -urw1 -h127.0.0.1 -e "select version()"
      """
    Given execute linux command in "dble-1"
      """
      mysql -P{node:client_port} -urw1 -h127.0.0.1 -Ddb2 -e "select version()"
      """
    Given execute linux command in "dble-1" and contains exception "Unknown database 'unkown'"
      """
      mysql -P{node:client_port} -urw1 -h127.0.0.1 -Dunkown -e "select version()"
      """
#### shardingUser
    Given execute linux command in "dble-1"
      """
      mysql -P{node:client_port} -utest -h127.0.0.1 -e "select version()"
      """
    Given execute linux command in "dble-1"
      """
      mysql -P{node:client_port} -utest -h127.0.0.1 -Dschema1 -e "select version()"
      """
    Given execute linux command in "dble-1" and contains exception "Unknown database 'unkown'"
      """
      mysql -P{node:client_port} -utest -h127.0.0.1 -Dunkown -e "select version()"
      """

#### managerUser
    Given execute linux command in "dble-1"
      """
      mysql -P{node:manager_port} -uroot -h127.0.0.1 -e "show @@version"
      """
    Given execute linux command in "dble-1"
      """
      mysql -P{node:manager_port} -uroot -h127.0.0.1 -Ddble_information -e "show tables"
      """
    Given execute linux command in "dble-1" and contains exception "Unknown database 'unkown'"
      """
      mysql -P{node:manager_port} -uroot -h127.0.0.1 -Dunkown -e "show tables"
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[MySQL Error Packet\] Unknown database
      """


  Scenario: check enableCheckSchema=0     #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
      """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DenableCheckSchema=0
      """
    Then Restart dble in "dble-1" success

#### rwSplitUser
    Given execute linux command in "dble-1"
      """
      mysql -P{node:client_port} -urw1 -h127.0.0.1 -e "select version()"
      """
    Given execute linux command in "dble-1"
      """
      mysql -P{node:client_port} -urw1 -h127.0.0.1 -Ddb2 -e "select version()"
      """

    Given execute linux command in "dble-1" and contains exception "Unknown database 'unkown'"
      """
      mysql -P{node:client_port} -urw1 -h127.0.0.1 -Dunkown -e "select 1"
      """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      \[MySQL Error Packet\] Unknown database
      """
#### shardingUser
    Given execute linux command in "dble-1"
      """
      mysql -P{node:client_port} -utest -h127.0.0.1 -e "select version()"
      """
    Given execute linux command in "dble-1"
      """
      mysql -P{node:client_port} -utest -h127.0.0.1 -Dschema1 -e "select version()"
      """
    Given execute linux command in "dble-1" and contains exception "Unknown database 'unkown'"
      """
      mysql -P{node:client_port} -utest -h127.0.0.1 -Dunkown -e "select version()"
      """

#### managerUser
    Given execute linux command in "dble-1"
      """
      mysql -P{node:manager_port} -uroot -h127.0.0.1 -e "show @@version"
      """
    Given execute linux command in "dble-1"
      """
      mysql -P{node:manager_port} -uroot -h127.0.0.1 -Ddble_information -e "show tables"
      """
    Given execute linux command in "dble-1" and contains exception "Unknown database 'unkown'"
      """
      mysql -P{node:manager_port} -uroot -h127.0.0.1 -Dunkown -e "show tables"
      """