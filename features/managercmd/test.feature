Feature:
  Scenario:#4 Some of datahosts cannot be connectted
  #4.1 Unable to connect to datahost does not exist readhost
  #4.2 Unable to connect to datahost has readhost
  Given start mysql in host "mysql-master1"
#    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
#    """
#    <schema name="mytest" sqlMaxLimit="100" dataNode="dn5">
#      <table name="test_shard" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" primaryKey="id"/>
#      <table name="test_two" dataNode="dn2,dn4" rule="hash-two" primaryKey="id"/>
#    </schema>
#
#    <dataHost balance="3" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="-1" switchType="1">
#  	  <heartbeat>select user()</heartbeat>
#  	  <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
#  	  <readHost host="hostS2" url="172.100.9.2:3306" password="111111" user="test"/>
#  	  </writeHost>
#    </dataHost>
#    """
#    Then execute admin cmd "reload @@config_all"
#    Then execute sql in "dble-1" in "user" mode
#      | user | passwd | conn   | toClose | sql                                                             | expect           | db     |
#      | test | 111111 | conn_0 | True    | drop table if exists test_shard                              | success         | mytest |
#      | test | 111111 | conn_0 | True    | drop table if exists test_two                                | success         | mytest |
#      | test | 111111 | conn_0 | True    | drop table if exists test_no_shard                           | success         | mytest |
#      | test | 111111 | conn_0 | True    | create table test_shard(id int,name char,age int)          | success         | mytest |
#      | test | 111111 | conn_0 | True    | create table test_two(id int,name char,age int)            | success         | mytest |
#      | test | 111111 | conn_0 | True    | create table test_no_shard(id int,name1 char,age int)     | success         | mytest |
#    #4.1
#    Given stop mysql in host "mysql-master1"
#    Given Restart dble in "dble-1" success
#    Then execute sql in "dble-1" in "user" mode
#      | user | passwd | conn   | toClose | sql                                                             | expect                        | db     |
#      | test | 111111 | conn_0 | True    | insert into test_shard values(1,1,1)                        | success                      | mytest |
#      | test | 111111 | conn_0 | True    | alter table test_two drop age                                | success                      | mytest |
#      | test | 111111 | conn_0 | True    | alter table test_shard drop name                            | Connection refused         | mytest |
#    Then execute sql in "dble-1" in "admin" mode
#      | user | passwd | conn   | toClose | sql                                                                         | expect                                 | db  |
#      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_shard' | hasStr{`name` }                       |     |
#      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_two'    | hasStr{`id` int(11) DEFAULT NULL}  |     |
#      | root | 111111 | conn_0 | True    | check full @@metadata where schema='mytest' and table='test_two'    | hasNoStr{`age`}                       |     |
#      | root | 111111 | conn_0 | True    | show @@version                                                             | success                                |     |
#      | root | 111111 | conn_0 | True    | reload @@metadata                                                          | success                                |     |
#    Given start mysql in host "mysql-master1"