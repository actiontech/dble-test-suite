# Created by zhaohongjie at 2018/10/15
Feature: check lower_case_table_names works right for dble
  lower_case_table_names=0, case insensitive
  lower_case_table_names=1, case sensitive

  @current
  Scenario:# test dataNode_caseSensitive ,whatever default dataNode is lower case or upper case ,dble should start success
    # 1. set default dataNode lowercase ,mysql lower_case_table_name = 0
    Given restart mysql in "mysql-master1" with options
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 0
     """
    Given restart mysql in "mysql-master2" with options
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 0
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    	<schema name="DBTEST">
            <table name="Test_Table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" >
	    </schema>
	"""
    Given delete the following xml segment
      |file        | parent           | child          |
      |server.xml  | {'tag':'root'}   | {'tag':'root'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
      <user name="root">
        <property name="password">111111</property>
        <property name="manager">true</property>
      </user>
      <user name="test">
        <property name="password">111111</property>
        <property name="schemas">mytest, DbTest</property>
      </user>
    """
    Given Restart dble in "dble-1"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                    | expect                             | db     |
        | test | 111111 | conn_0 | False    | drop table if exists Aly_Test(id int)  | success                            | DbTest |
        | test | 111111 | conn_0 | False    | drop table if exists Aly_Test(id int)  | success                            | Mytest |
        | test | 111111 | conn_0 | False    | show full tables                              | has{('test_table','BASE TABLE')}   | mytest |
        | test | 111111 | conn_0 | True    | drop table test_table                         | success                            | mytest |

