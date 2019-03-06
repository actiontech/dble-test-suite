# Created by yexiaoli at 2019/3/5
Feature: show_datasource

  Scenario: verify manage-cmd show @@datasource
             requirment from github issue #942: result should not display negative number for "ACTIVE" column
    
     Given stop mysql in host "mysql-master1"
     Given Restart dble in "dble-1" success
     Then execute sql in "dble-1" in "admin" mode
        | user  | passwd    | conn   | toClose | sql                     | expect                                                                               | db  |
        | root  | 111111    | conn_0 | True    | show @@datasource     | has{('hostM1', '172.100.9.5', 3306L, 'W', 0L, 0L, 1000L, 0L, 0L, 0L)}       |     |
     Given start mysql in host "mysql-master1"