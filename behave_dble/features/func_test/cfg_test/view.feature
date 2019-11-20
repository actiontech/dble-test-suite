# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/5/7
Feature: #view test except sql cover

  Scenario: # start dble when the configuration does not include the tables involved in the view  from issue:1100 #1
     Then  execute sql in "dble-1" in "user" mode
       | user | passwd | conn   | toClose  | sql                                                | expect  | db       |
       | test | 111111 | conn_0 | True     | drop table if exists test                       | success | schema1 |
       | test | 111111 | conn_0 | True     | create table test(id int)                        | success | schema1 |
       | test | 111111 | conn_0 | True     | drop view if exists view_test                   | success | schema1 |
       | test | 111111 | conn_0 | True     | create view view_test as select * from test   | success | schema1 |
     Given delete the following xml segment
       |file         | parent           | child               |
       |schema.xml  |{'tag':'root'}   | {'tag':'schema'}   |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
        <schema name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn3" name="test1" type="global" />
        </schema>
     """
     Then execute admin cmd "reload @@config_all"
     Given Restart dble in "dble-1" success
     Then execute sql in "dble-1" in "user" mode
       | user | passwd | conn   | toClose  | sql                          | expect                                                                                                                                       | db     |
       | test | 111111 | conn_0 | True     | select * from view_test   | View 'view_test' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them | schema1 |
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
     """
        <table dataNode="dn1,dn2,dn3,dn4" name="test" type="global" />
     """
     Then execute admin cmd "reload @@config_all"
     Then execute sql in "dble-1" in "user" mode
       | user | passwd | conn   | toClose  | sql                          | expect    | db     |
       | test | 111111 | conn_0 | True     | select * from view_test   | success   | schema1 |
       | test | 111111 | conn_0 | True     | drop view view_test        | success   | schema1 |

