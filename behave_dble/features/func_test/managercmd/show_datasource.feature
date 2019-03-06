# Created by yexiaoli at 2019/3/5
Feature: show_datasource

  Scenario: verify manage-cmd show @@datasource
             requirment from github issue #942: result should not display negative number for "ACTIVE" column #1
    
     Given stop mysql in host "mysql-master1"
     Then get resultset of admin cmd "show @@datasource" named "sql_rs"
     Then check resultset "sql_rs" has lines with following column values
        | NAME-0 | HOST-1         |  PORT-2 | ACTIVE-4  |
        | hostM1 | 172.100.9.5   | 3306     |    0      |
     Given start mysql in host "mysql-master1"