# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/13 下午12:14
# @Author  : irene-coming
Feature: dble start fail if global var lower_case_table_names are not consistent in all dataHosts
#  lower_case_table_names default value in mysql under linux is 0

  @restore_letter_sensitive @current
  Scenario: dble start fail if global var lower_case_table_names of writeHosts are not consistent in 2 dataHosts #1
    """
    {'restore_letter_sensitive':['mysql-master1']}
    """
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
#    in template config, there has 2 dataHosts, dataHost's default lower_case_table_names is 0
    Then restart dble in "dble-1" failed for
    """
    The values of lower_case_table_names for backend MySQLs are different
    """

  @restore_letter_sensitive
  Scenario: dble start fail if global var lower_case_table_names are not consistent between readHost and writeHost #2
    """
    {'restore_letter_sensitive':['mysql-master2']}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="2" maxCon="9" minCon="3" name="ha_group2" slaveThreshold="100" >
       <heartbeat>select user()</heartbeat>
       <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
          <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
       </writeHost>
    </dataHost>
    """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
    Then restart dble in "dble-1" failed for
    """
    The values of lower_case_table_names for backend MySQLs are different
    """

  @restore_letter_sensitive @skip
  Scenario: dble reload fail if global var lower_case_table_names are not consistent between new added writehost and the old ones' #3
    """
    {'restore_letter_sensitive':['mysql-master2']}
    """
    Given delete the following xml segment
      |file        | parent          | child                                             |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost','kv_map':{'name':'ha_group1'}}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="2" maxCon="9" minCon="3" name="ha_group2" slaveThreshold="100" >
       <heartbeat>select user()</heartbeat>
       <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
          <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
       </writeHost>
    </dataHost>
    """
    Given restart dble in "dble-1" success
    Given execute sql in "mysql-master1"
      | user  | passwd    | conn   | toClose | sql                                      | expect  |db |
      | test  | 111111    | conn_0 | true    | set global lower_case_table_names=1      | success |   |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
        </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    abcdefg
    """
