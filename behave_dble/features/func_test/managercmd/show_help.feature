# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/03/11


Feature: test show @@help

  @NORMAL
  Scenario: test "show @@help" #1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                     | expect        |
      | conn_0 | False   | show @@help             | length{(97)}  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_A"
      | sql         |
      | show @@help |
    Then check resultset "rs_A" has lines with following column values
      | STATEMENT-0                                                                                      | DESCRIPTION-1                                                                     |
      | select @@VERSION_COMMENT;                                                                        | Show the version comment of dble                                                  |
      | show @@time.current                                                                              | Report current timestamp                                                          |
      | show @@time.startup                                                                              | Report startup timestamp                                                          |
      | show @@version                                                                                   | Report Server version                                                             |
      | show @@server                                                                                    | Report server status                                                              |
      | show @@threadpool                                                                                | Report threadPool status                                                          |
      | show @@database                                                                                  | Report databases                                                                  |
      | show @@datanode [where schema = ?]                                                               | Report dataNodes                                                                  |
      | show @@datasource [where dataNode = ?]                                                           | Report dataSources                                                                |
      | show @@datasource.synstatus                                                                      | Report datasource data synchronous                                                |
      | show @@datasource.syndetail where name=?                                                         | Report datasource data synchronous detail                                         |
      | show @@datasource.cluster                                                                        | Report datasource galary cluster variables                                        |
      | show @@processor                                                                                 | Report processor status                                                           |
      | show @@command                                                                                   | Report commands status                                                            |
      | show @@connection where processor=? and front_id=? and host=? and user=?                         | Report connection status                                                          |
      | show @@cache                                                                                     | Report system cache usage                                                         |
      | show @@backend where processor=? and backend_id=? and mysql_id=? and host=? and port=?           | Report backend connection status                                                  |
      | show @@session                                                                                   | Report front session details                                                      |
      | show @@session.xa                                                                                | Report front session and associated xa transaction details                        |
      | show @@connection.sql                                                                            | Report connection sql                                                             |
      | show @@connection.sql.status where FRONT_ID= ?;                                                  | Show current connection sql status and detail                                     |
      | show @@sql                                                                                       | Report SQL list                                                                   |
      | show @@sql.high                                                                                  | Report Hight Frequency SQL                                                        |
      | show @@sql.slow                                                                                  | Report slow SQL                                                                   |
      | show @@sql.large                                                                                 | Report the sql witch resultset larger than 10000 rows                             |
      | show @@sql.condition                                                                             | Report the query of a specific table.column set by reload query_cf                |
      | show @@sql.resultset                                                                             | Report BIG RESULTSET SQL                                                          |
      | show @@sql.sum                                                                                   | Report  User RW Stat                                                              |
      | show @@sql.sum.user                                                                              | Report  User RW Stat                                                              |
      | show @@sql.sum.table                                                                             | Report  Table RW Stat                                                             |
      | show @@heartbeat                                                                                 | Report heartbeat status                                                           |
      | show @@heartbeat.detail where name=?                                                             | Report heartbeat current detail                                                   |
      | show @@sysparam                                                                                  | Report system param                                                               |
      | show @@syslog limit=?                                                                            | Report system log                                                                 |
      | show @@white                                                                                     | Report server white host                                                          |
      | show @@directmemory                                                                              | Report server direct memory pool usage                                            |
      | show @@command.count                                                                             | Report the current number of querys                                               |
      | show @@connection.count                                                                          | Report the current number of connections                                          |
      | show @@backend.statistics                                                                        | Report backend node info                                                          |
      | show @@backend.old                                                                               | Report old connections witch still alive after reload config all                  |
      | show @@binlog.status                                                                             | Report the current GTID of all backend nodes                                      |
      | show @@help                                                                                      | Report usage of manager port                                                      |
      | show @@processlist                                                                               | Report correspondence between front and backend session                           |
      | show @@cost_time                                                                                 | Report cost time of query , contains back End ,front End and over all             |
      | show @@thread_used                                                                               | Report all bussiness&reactor thread usage                                         |
      | show @@algorithm where schema='?' and table='?'                                                  | Report the algorithm info of a table                                              |
      | show @@ddl                                                                                       | Report all ddl info in progress                                                   |
      | show @@reload_status                                                                             | Report latest reload status in this dble                                          |
      | show @@user                                                                                      | Report all user in this dble                                                      |
      | show @@user.privilege                                                                            | Report privilege of all business user in this dble                                |
      | show @@questions                                                                                 | Report the questions & transactions have been executed in server port             |
      | show @@data_distribution where table ='schema.table'                                             | Report the data distribution in different data node                               |
      | switch @@datasource name:index                                                                   | Switch dataSource                                                                 |
      | kill @@connection id1,id2,...                                                                    | Kill the specified connections                                                    |
      | kill @@xa_session id1,id2,...                                                                    | Kill the specified sessions that commit/rollback xa transaction in the background |
      | kill @@ddl_lock where schema='?' and table='?'                                                   | Kill ddl lock held by the specified ddl                                           |
      | stop @@heartbeat name:time                                                                       | Pause dataNode heartbeat                                                          |
      | reload @@config                                                                                  | Reload basic config from file                                                     |
      | reload @@config_all                                                                              | Reload all config from file                                                       |
      | reload @@metadata [where schema=? [and table=?] \| where table in ('schema1.table1',...)]         | Reload metadata of tables or specified table                                     |
      | reload @@sqlslow=                                                                                | Set Slow SQL Time(ms)                                                             |
      | reload @@user_stat                                                                               | Reset show @@sql  @@sql.sum @@sql.slow                                            |
      | reload @@query_cf[=table&column]                                                                 | Reset show @@sql.conditiont                                                       |
      | release @@reload_metadata                                                                        | Release reload process , unlock the config meta lock                              |
      | rollback @@config                                                                                | Rollback all config from memory                                                   |
      | offline                                                                                          | Change Server status to OFF                                                       |
      | online                                                                                           | Change Server status to ON                                                        |
      | file @@list                                                                                      | List all the file in conf directory                                               |
      | file @@show filename                                                                             | Show the file data of specific file                                               |
      | file @@upload filename content                                                                   | Write content to file                                                             |
      | log @@[file=? limit=? key=? regex=?]                                                             | Report logs by given regex                                                        |
      | dryrun                                                                                           | Dry run to check config before reload xml                                         |
      | pause @@DataNode                                                                                 | Block query requests witch specified dataNodes involved                           |
      | RESUME                                                                                           | Resume the query requests of the paused dataNodes                                 |
      | show @@pause                                                                                     | Show which dataNodes have bean pause                                              |
      | show @@slow_query_log                                                                            | Show if the slow query log is enabled                                             |
      | enable @@slow_query_log                                                                          | Turn on the slow query log                                                        |
      | disable @@slow_query_log                                                                         | Turn off the slow query log                                                       |
      | show @@slow_query.time                                                                           | Show the threshold of slow sql, the unit is millisecond                           |
      | reload @@slow_query.time                                                                         | Reset the threshold of slow sql                                                   |
      | show @@slow_query.flushperiod                                                                    | Show the min flush period for writing to disk                                     |
      | reload @@slow_query.flushperiod                                                                  | Reset the flush period                                                            |
      | show @@slow_query.flushsize                                                                      | Show the min flush size for writing to disk                                       |
      | reload @@slow_query.flushsize                                                                    | Reset the flush size                                                              |
      | create database @@dataNode ='dn......'                                                           | create database for datanode setted in schema.xml                                 |
      | check @@metadata                                                                                 | show last time of `reload @@metadata`/start dble                                  |
      | check @@global (schema = '?'( and table = '?'))                                                  | check global and get check result immediately                                     |
      | check full @@metadata                                                                            | show detail information of metadata                                               |
      | show @@alert                                                                                     | Show if the alert is enabled                                                      |
      | enable @@alert                                                                                   | Turn on the alert                                                                 |
      | disable @@alert                                                                                  | Turn off the alert                                                                |
      | dataHost @@disable name='?' (node = '?')                                                         | disable some dataSources/dataHost                                                 |
      | dataHost @@enable name='?' (node = '?')                                                          | enable some dataSources/dataHost                                                  |
      | dataHost @@switch name='?' master='?'                                                            | switch writeHost and readHost in one dataHost                                     |
      | dataHost @@events                                                                                | show all the dataHost ha event which not finished yet                             |
      | split src dest -sschema -r500 -w500 -l10000                                                      | split dump file into multi dump files according to dataNode                       |