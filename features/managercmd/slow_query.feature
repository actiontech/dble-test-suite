Feature:#test reference manager cmd  and main function for slow query log
   @regression
   Scenario:# 1.test manager cmd for slow query log
      #1.1 test enable @@slow_query_log
      #1.2 test disable @@slow_query_log
      #1.3 test show @@slow_query_log
      Then execute sql in "dble-1" in "admin" mode
        | user  | passwd    | conn   | toClose | sql                        | expect       | db  |
        | root  | 111111    | conn_0 | False   | enable @@slow_query_log | success      |     |
        | root  | 111111    | conn_0 | False   | show @@slow_query_log   | has{('1',)}  |     |
        | root  | 111111    | conn_0 | False   | disable @@slow_query_log| success      |     |
        | root  | 111111    | conn_0 | True    | show @@slow_query_log    | has{('0',)} |     |

      #1.3 test show @@slow_query.time, reload @@slow_query.time
      #1.4 test show @@slow_query.flushperid, reload @@slow_query.flushperid
      #1.5 test show @@slow_query.flushsize, reload @@slow_query.flushsize
      Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
      """
      <system>
           <property name="enableSlowLog">1 </property>
		    <property name="sqlSlowTime">30 </property>
		    <property name="flushSlowLogPeriod">1000 </property>
           <property name="flushSlowLogSize">5 </property>
      </system>
      """
       Given Restart dble in "dble-1" success
       Then execute sql in "dble-1" in "admin" mode
        | user   | passwd  | conn   | toClose | sql                                         | expect         | db |
        | root   | 111111  | conn_0 | False   | show @@slow_query.time                   | has{('30',)}  |    |
        | root   | 111111  | conn_0 | False   | reload @@slow_query.time = 200          | success        |    |
        | root   | 111111  | conn_0 | False   | show @@slow_query.time                   | has{('200',)}  |    |

        | root   | 111111  | conn_0 | False   | show @@slow_query.flushperiod           | has{('1000',)} |    |
        | root   | 111111  | conn_0 | False   | reload @@slow_query.flushperiod = 200  | success         |    |
        | root   | 111111  | conn_0 | False   | show @@slow_query.flushperiod           | has{('200',)}  |    |

        | root   | 111111  | conn_0 | False   | show @@slow_query.flushsize             | has{('5',)}     |    |
        | root   | 111111  | conn_0 | False   | reload @@slow_query.flushsize = 50     | success         |    |
        | root   | 111111  | conn_0 | True    | show @@slow_query.flushsize             | has{('50',)}    |    |
   @regression
   Scenario:# 2.test main function of slow query log
      Given delete "/opt/dble/slowQuery" on "dble-1"
      Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
      """
       <system>
            <property name="enableSlowLog">1</property>
            <property name="slowLogBaseDir">./slowQuery</property>
            <property name="slowLogBaseName">query</property>
            <property name="sqlSlowTime">1</property>
       </system>
     """
      Given Restart dble in "dble-1" success
      Then check following " " exist in dir "/opt/dble/" in "dble-1"
      """
      slowQuery
      query.log
      """
      Then execute sql in "dble-1" in "admin" mode
        | user         | passwd    | conn   | toClose  | sql                                      | expect  | db     |
        | root         | 111111    | conn_0 | True     | disable @@slow_query_log              |  success  |   |
      Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose  | sql                                        | expect    | db     |
        | test         | 111111    | conn_0 | False    | drop table if exists a_test            |  success  |   mytest|
        | test         | 111111    | conn_0 | False    | create table a_test(id int)            |  success  |   mytest|
        | test         | 111111    | conn_0 | False    | alter table a_test add name char(20)  |  success  |   mytest|
        | test         | 111111    | conn_0 | False    | insert into a_test values(1,'a_test1')|  success  |   mytest|
        | test         | 111111    | conn_0 | False    | select id from a_test                    |  success  |   mytest|
        | test         | 111111    | conn_0 | False    | select count(id) from a_test            |  success  |   mytest|
        | test         | 111111    | conn_0 | True     | delete from a_test                        |  success  |   mytest|

      Then check following "not" exist in file "/opt/dble/slowQuery/query.log" in "dble-1"
      """
      drop table if exists a_test
      create table a_test(id int)
      alter table a_test add name char(20)
      insert into a_test values(1,'a_test1')
      select id from a_test
      select count(id) from a_test
      delete from a_test
      """
    Then execute sql in "dble-1" in "admin" mode
        | user         | passwd    | conn   | toClose | sql                        | expect  | db     |
        | root         | 111111    | conn_0 | True    | enable @@slow_query_log |  success  |   |
      Then execute sql in "dble-1" in "user" mode
        | user         | passwd    | conn   | toClose  | sql                                         | expect  | db     |
        | test         | 111111    | conn_0 | False    | drop table if exists a_test             |  success  |   mytest|
        | test         | 111111    | conn_0 | False    | create table a_test(id int)             |  success  |   mytest|
        | test         | 111111    | conn_0 | False    | alter table a_test add name char(20)   |  success  |   mytest|
        | test         | 111111    | conn_0 | False    | insert into a_test values(1,'a_test1') |  success  |   mytest|
        | test         | 111111    | conn_0 | False    | select id from a_test                     |  success  |   mytest|
        | test         | 111111    | conn_0 | False    | select count(id) from a_test             |  success  |   mytest|
        | test         | 111111    | conn_0 | True     | delete from a_test                         |  success  |   mytest|

      Then check following " " exist in file "/opt/dble/slowQuery/query.log" in "dble-1"
      """
      drop table if exists a_test
      create table a_test(id int)
      alter table a_test add name char(20)
      insert into a_test values(1,'a_test1')
      select id from a_test
      select count(id) from a_test
      delete from a_test
      """
