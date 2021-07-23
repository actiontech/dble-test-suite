# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by caiwei at 2021/03/11

Feature: case about load data batch

  Scenario: Manger CMD enable/disable @@load_data_batch    #1
    #CASE TEST "disable @@load_data_batch"
    Then execute admin cmd "disable @@load_data_batch"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | conn   | toClose  | sql                                                                                                                   | db               |
      | conn_0 | true     | select * from dble_information.dble_variables where variable_name in ('enableBatchLoadData','maxRowSizeToFile')       | dble_information |
    Then check resultset "A" has lines with following column values
      | variable_name-0     | variable_value-1 | comment-2                                                                                                         | read_only-3 |
      | maxRowSizeToFile    | 100000           | The maximum row size,if over this value,row data will be saved to file when load data.The default value is 100000 | false       |
      | enableBatchLoadData | false            | Enable Batch Load Data. The default value is false                                                                | false       |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      enableBatchLoadData=0
      """

    #CASE TEST enable @@load_data_batch
    Then execute admin cmd "enable @@load_data_batch"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
      | conn   | toClose | sql                                                                                                                   | db               |
      | conn_0 | true    | select * from dble_information.dble_variables where variable_name in ('enableBatchLoadData','maxRowSizeToFile')       | dble_information |
    Then check resultset "B" has lines with following column values
      | variable_name-0     | variable_value-1 | comment-2                                                                                                         | read_only-3 |
      | maxRowSizeToFile    | 100000           | The maximum row size,if over this value,row data will be saved to file when load data.The default value is 100000 | false       |
      | enableBatchLoadData | true             | Enable Batch Load Data. The default value is false                                                                | false       |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      enableBatchLoadData=1
      """

    #CASE TEST repeat execute enable/disable @@load_data_batch
    Then execute admin cmd "enable @@load_data_batch"
    Then execute admin cmd "disable @@load_data_batch"
    Then execute admin cmd "enable @@load_data_batch"
    Then execute admin cmd "disable @@load_data_batch"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | conn   | toClose | sql                                                                                                                   | db               |
      | conn_0 | true    | select * from dble_information.dble_variables where variable_name in ('enableBatchLoadData','maxRowSizeToFile')       | dble_information |
    Then check resultset "C" has lines with following column values
      | variable_name-0     | variable_value-1 | comment-2                                                                                                         | read_only-3 |
      | maxRowSizeToFile    | 100000           | The maximum row size,if over this value,row data will be saved to file when load data.The default value is 100000 | false       |
      | enableBatchLoadData | false            | Enable Batch Load Data. The default value is false                                                                | false       |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      enableBatchLoadData=0
      """

  Scenario: Manger CMD reload @@load_data.num        #2
    #CASE  reload @@load_data.num --> Illegal value
    Then execute admin cmd "enable @@load_data_batch"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                     | expect                                                        |
      | conn_0 | False   | reload @@load_data.num = 0                              | must be of numeric type and the value must be greater than 0  |
      | conn_0 | False   | reload @@load_data.num = -1                             | must be of numeric type and the value must be greater than 0  |
      | conn_0 | False   | reload @@load_data.num = 999%                           | must be of numeric type and the value must be greater than 0  |
      | conn_0 | False   | reload @@load_data.num = 999.99                         | must be of numeric type and the value must be greater than 0  |
      | conn_0 | False   | reload @@load_data.num = a                              | must be of numeric type and the value must be greater than 0  |
      | conn_0 | False   | reload @@load_data.num = ?                              | must be of numeric type and the value must be greater than 0  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | conn   | toClose  | sql                                                                                                                   | db               |
      | conn_0 | true     | select * from dble_information.dble_variables where variable_name in ('enableBatchLoadData','maxRowSizeToFile')       | dble_information |
    Then check resultset "A" has lines with following column values
      | variable_name-0     | variable_value-1 | comment-2                                                                                                         | read_only-3 |
      | maxRowSizeToFile    | 100000           | The maximum row size,if over this value,row data will be saved to file when load data.The default value is 100000 | false       |
      | enableBatchLoadData | true             | Enable Batch Load Data. The default value is false                                                                | false       |
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      enableBatchLoadData=1
      """

      #CASE reload @@load_data.num --> Legal value
      Then execute admin cmd "enable @@load_data_batch"
      Then execute sql in "dble-1" in "admin" mode
        | conn   | toClose | sql                                                        | db                |
        | conn_0 | False   | reload @@load_data.num = 500                               | dble_information  |
        | conn_0 | False   | reload @@load_data.num = 5000                              | dble_information  |
        | conn_0 | False   | reload @@load_data.num = 50000                             | dble_information  |
      Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
        | conn   | toClose  | sql                                                                                                                   | db               |
        | conn_0 | true     | select * from dble_information.dble_variables where variable_name in ('enableBatchLoadData','maxRowSizeToFile')       | dble_information |
      Then check resultset "B" has lines with following column values
        | variable_name-0         | variable_value-1 |
        | maxRowSizeToFile        | 50000            |
        | enableBatchLoadData     | true             |
      Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      enableBatchLoadData=1
      maxRowSizeToFile=50000
      """

      #CASE after changing load_data.num,then execute disable @@load_data_batch and check the status
      Then execute admin cmd "disable @@load_data_batch"
      Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
        | conn   | toClose  | sql                                                                                                                   | db               |
        | conn_0 | true     | select * from dble_information.dble_variables where variable_name in ('enableBatchLoadData','maxRowSizeToFile')       | dble_information |
      Then check resultset "C" has lines with following column values
        | variable_name-0         | variable_value-1 |
        | maxRowSizeToFile        | 50000            |
        | enableBatchLoadData     | false            |
      Then execute admin cmd "reload @@load_data.num=60000"
      Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      enableBatchLoadData=0
      maxRowSizeToFile=60000
      """
      Given restart dble in "dble-1" success
      Given execute single sql in "dble-1" in "admin" mode and save resultset in "D"
        | conn   | toClose  | sql                                                                                                                   | db               |
        | conn_1 | true     | select * from dble_information.dble_variables where variable_name in ('enableBatchLoadData','maxRowSizeToFile')       | dble_information |
      Then check resultset "D" has lines with following column values
        | variable_name-0         | variable_value-1 |
        | maxRowSizeToFile        | 60000            |
        | enableBatchLoadData     | false            |

  @btrace
  Scenario: test with Btrace script to check file slice is right     #3
    #Preparation: Create test file and table  for loading data
    Given execute oscmd in "dble-1"
    """
    rm -rf /opt/dble/data.txt
    """
    Given execute oscmd in "dble-1"
    """
    echo -e '1,1\n2,2\n3,3\n4,4\n5,5\n6,6\n7,7\n8,8\n9,9\n10,10\n11,11\n12,12\n13,13' > /opt/dble/data.txt
    """
    Given connect "dble-1" with user "test" in "dble-1" to execute sql
    """
    drop table if exists schema1.sharding_2_t1
    drop table if exists schema1.test
    drop table if exists schema1.test1
    create table schema1.sharding_2_t1(id int,c int)
    create table schema1.test(id int,c int)
    create table schema1.test1(id int,c int)
    """
    Then execute admin cmd "enable @@load_data_batch"
    Then execute admin cmd "reload @@load_data.num=2"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | conn   | toClose   | sql                                                                                                                   | db               |
      | conn_0 | true      | select * from dble_information.dble_variables where variable_name in ('enableBatchLoadData','maxRowSizeToFile')       | dble_information |
    Then check resultset "A" has lines with following column values
      | variable_name-0         | variable_value-1 |
      | maxRowSizeToFile        | 2                |
      | enableBatchLoadData     | true             |

    #CASE1:  execute load data  with Btrace script to check file slice is right
    Given delete file "/opt/dble/BtraceAboutLoadDataBatch.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutLoadDataBatch.java.log" on "dble-1"
    Given update file content "./assets/BtraceAboutLoadDataBatch.java" in "behave" with sed cmds
    """
     s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
     /delayBeforeLoadData/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAboutLoadDataBatch.java" in "dble-1"

    # for Multi-node-sharding table
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose   | sql                                                                                                                       |  db      |
      | conn_0 | true      | load data infile '/opt/dble/data.txt' into table schema1.sharding_2_t1 fields terminated by ',' lines terminated by '\n'  |  schema1 |
    Given sleep "2" seconds
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check following "Y" exist in dir "/opt/dble/temp/file" in "dble-1"
    """
    1-data-sharding_2_t1-dn1.txt
    1-data-sharding_2_t1-dn2.txt
    2-data-sharding_2_t1-dn1.txt
    2-data-sharding_2_t1-dn2.txt
    3-data-sharding_2_t1-dn1.txt
    3-data-sharding_2_t1-dn2.txt
    """
    Then check following text exist "Y" in file "/opt/dble/temp/file/3-data-sharding_2_t1-dn1.txt" in host "dble-1"
    """
    10,10
    12,12
    """
    Then check following text exist "Y" in file "/opt/dble/temp/file/3-data-sharding_2_t1-dn2.txt" in host "dble-1"
    """
    9,9
    11,11
    13,13
    """
    Given sleep "3" seconds
    #check data.txt successfully load data into table "sharding_2_t1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect          | db      |
      | conn_1 | true    | select * from schema1.sharding_2_t1    | length{(13)}    | schema1 |
    #check dir /opt/dble/temp/file is deleted
    Then check path "/opt/dble/temp/file" in "dble-1" should not exist

    #for Multi-node-global table
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose   | sql                                                                                                                       |  db      |
      | conn_0 | true      | load data infile '/opt/dble/data.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'           |  schema1 |
    Given sleep "2" seconds
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check following "Y" exist in dir "/opt/dble/temp/file" in "dble-1"
    """
    1-data-test-dn1.txt
    2-data-test-dn1.txt
    3-data-test-dn1.txt
    4-data-test-dn1.txt
    5-data-test-dn1.txt
    6-data-test-dn1.txt
    1-data-test-dn2.txt
    2-data-test-dn2.txt
    3-data-test-dn2.txt
    4-data-test-dn2.txt
    5-data-test-dn2.txt
    6-data-test-dn2.txt
    1-data-test-dn3.txt
    2-data-test-dn3.txt
    3-data-test-dn3.txt
    4-data-test-dn3.txt
    5-data-test-dn3.txt
    6-data-test-dn3.txt
    1-data-test-dn4.txt
    2-data-test-dn4.txt
    3-data-test-dn4.txt
    4-data-test-dn4.txt
    5-data-test-dn4.txt
    6-data-test-dn4.txt
    """
    Then check following text exist "Y" in file "/opt/dble/temp/file/6-data-test-dn1.txt" in host "dble-1"
    """
    11,11
    12,12
    13,13
    """
    Given sleep "3" seconds
    #check data.txt successfully load data into table "test"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                    | expect          | db      |
      | conn_1 | true    | select * from schema1.test             | length{(13)}    | schema1 |
    #check dir /opt/dble/temp/file is deleted
    Then check path "/opt/dble/temp/file" in "dble-1" should not exist

    #for single-node table
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose   | sql                                                                                                                       |  db      |
      | conn_0 | true      | load data infile '/opt/dble/data.txt' into table schema1.test1 fields terminated by ',' lines terminated by '\n'          |  schema1 |
    Given sleep "2" seconds
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check following "Y" exist in dir "/opt/dble/temp/file" in "dble-1"
    """
    1-data-test1-dn5.txt
    2-data-test1-dn5.txt
    3-data-test1-dn5.txt
    4-data-test1-dn5.txt
    5-data-test1-dn5.txt
    6-data-test1-dn5.txt
    """
    Then check following text exist "Y" in file "/opt/dble/temp/file/6-data-test1-dn5.txt" in host "dble-1"
    """
    11,11
    12,12
    13,13
    """
    Given sleep "3" seconds
    #check data.txt successfully load data into table "test1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect          | db      |
      | conn_2 | true    | select * from schema1.test1                  | length{(13)}    | schema1 |
    #check dir /opt/dble/temp/file is deleted
    Then check path "/opt/dble/temp/file" in "dble-1" should not exist
    Then check btrace "BtraceAboutLoadDataBatch.java" output in "dble-1" with "3" times
    """
    get into delayBeforeLoadData
    """
    Given stop btrace script "BtraceAboutLoadDataBatch.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceAboutLoadDataBatch.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutLoadDataBatch.java.log" on "dble-1"
    Given delete file "/opt/dble/data.txt" on "dble-1"

  Scenario: test something wrong with file , the logic of load data batch          #4
    #for Multi-node-sharding table
    Given execute oscmd in "dble-1"
    """
    rm -rf /opt/dble/data.txt
    """
    Given execute oscmd in "dble-1"
    """
    echo -e '1,1\n2,2\n3,3\n4,4\n5,5\n6,a\n7,7\n8,8\n9,9\n10,10\n11,11\n12,12\n13,13' > /opt/dble/data.txt
    """
    Given connect "dble-1" with user "test" in "dble-1" to execute sql
    """
    drop table if exists schema1.sharding_2_t1
    drop table if exists schema1.test
    drop table if exists schema1.test1
    create table schema1.sharding_2_t1(id int,c int)
    create table schema1.test(id int,c int)
    create table schema1.test1(id int,c int)
    """
    Then execute admin cmd "enable @@load_data_batch"
    Then execute admin cmd "reload @@load_data.num=2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect          | db      |
      | conn_0 | true    | load data infile '/opt/dble/data.txt' into table schema1.sharding_2_t1 fields terminated by ',' lines terminated by '\n'   | success         | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check path "/opt/dble/temp/error" in "dble-1" should exist
    Then check following "Y" exist in dir "/opt/dble/temp/file" in "dble-1"
    """
    2-data-sharding_2_t1-dn1.txt
    3-data-sharding_2_t1-dn1.txt
    """
    Then check following "Y" exist in dir "/opt/dble/temp/error" in "dble-1"
    """
    2-data-sharding_2_t1-dn1.txt
    """
    Then check following text exist "Y" in file "/opt/dble/temp/error/2-data-sharding_2_t1-dn1.txt" in host "dble-1"
    """
    6,a
    8,8
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                                               | db      |
      | conn_0 | False   | select * from schema1.sharding_2_t1  | length{(9)}                                                          | schema1 |
      | conn_0 | true    | select * from schema1.sharding_2_t1  | has{((1,1),(2,2),(3,3),(4,4),(5,5),(7,7),(9,9),(11,11),(13,13))}     | schema1 |
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,a/6,6/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect          | db      |
      | conn_0 | true    | load data infile '/opt/dble/data.txt' into table schema1.sharding_2_t1 fields terminated by ',' lines terminated by '\n'   | success         | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                             | expect                                 | db      |
      | conn_0 | False   | select * from schema1.sharding_2_t1                             | length{(13)}                           | schema1 |
      | conn_0 | true    | select * from schema1.sharding_2_t1 where id>5 and mod(id,2)=0  | has{((6,6),(8,8),(10,10),(12,12))}     | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should not exist
    Then check path "/opt/dble/temp/error" in "dble-1" should not exist

    #for Multi-node-global table
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,6/6,a/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                               | expect          | db      |
      | conn_1 | true    | load data infile '/opt/dble/data.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'   | success         | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check path "/opt/dble/temp/error" in "dble-1" should exist
    Then check following "Y" exist in dir "/opt/dble/temp/file" in "dble-1"
    """
    3-data-test-dn1.txt
    4-data-test-dn1.txt
    5-data-test-dn1.txt
    6-data-test-dn1.txt
    3-data-test-dn2.txt
    4-data-test-dn2.txt
    5-data-test-dn2.txt
    6-data-test-dn2.txt
    3-data-test-dn3.txt
    4-data-test-dn3.txt
    5-data-test-dn3.txt
    6-data-test-dn3.txt
    3-data-test-dn4.txt
    4-data-test-dn4.txt
    5-data-test-dn4.txt
    6-data-test-dn4.txt
    """
    Then check following "Y" exist in dir "/opt/dble/temp/error" in "dble-1"
    """
    3-data-test-dn1.txt
    3-data-test-dn2.txt
    3-data-test-dn3.txt
    3-data-test-dn4.txt
    """
    Then check following text exist "Y" in file "/opt/dble/temp/error/3-data-test-dn1.txt" in host "dble-1"
    """
    5,5
    6,a
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                               | expect                            | db      |
      | conn_1 | False   | select * from schema1.test        | length{(4)}                       | schema1 |
      | conn_1 | true    | select * from schema1.test        | has{((1,1),(2,2),(3,3),(4,4))}    | schema1 |
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,a/6,6/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                               | expect          | db      |
      | conn_1 | true    | load data infile '/opt/dble/data.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'   | success         | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                           | expect                                                                                           | db      |
      | conn_1 | False   | select * from schema1.test    | length{(13)}                                                                                     | schema1 |
      | conn_1 | true    | select * from schema1.test    | has{((1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),(11,11),(12,12),(13,13))}     | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should not exist
    Then check path "/opt/dble/temp/error" in "dble-1" should not exist

    #for single-node table
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,6/6,a/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                | expect          | db      |
      | conn_2 | true    | load data infile '/opt/dble/data.txt' into table schema1.test1 fields terminated by ',' lines terminated by '\n'   | success         | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check path "/opt/dble/temp/error" in "dble-1" should exist
    Then check following "Y" exist in dir "/opt/dble/temp/file" in "dble-1"
    """
    3-data-test1-dn5.txt
    4-data-test1-dn5.txt
    5-data-test1-dn5.txt
    6-data-test1-dn5.txt
    """
    Then check following "Y" exist in dir "/opt/dble/temp/error" in "dble-1"
    """
    3-data-test1-dn5.txt
    """
    Then check following text exist "Y" in file "/opt/dble/temp/error/3-data-test1-dn5.txt" in host "dble-1"
    """
    5,5
    6,a
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                               | expect                            | db      |
      | conn_2 | False   | select * from schema1.test1       | length{(4)}                       | schema1 |
      | conn_2 | true    | select * from schema1.test1       | has{((1,1),(2,2),(3,3),(4,4))}    | schema1 |
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,a/6,6/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                | expect          | db      |
      | conn_2 | true    | load data infile '/opt/dble/data.txt' into table schema1.test1 fields terminated by ',' lines terminated by '\n'   | success         | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect                                                                                           | db      |
      | conn_2 | False   | select * from schema1.test            | length{(13)}                                                                                     | schema1 |
      | conn_2 | False   | select * from schema1.test            | has{((1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),(11,11),(12,12),(13,13))}     | schema1 |
      | conn_2 | False   | truncate schema1.sharding_2_t1        | success                                                                                          | schema1 |
      | conn_2 | False   | truncate schema1.test                 | success                                                                                          | schema1 |
      | conn_2 | true    | truncate schema1.test1                | success                                                                                          | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should not exist
    Then check path "/opt/dble/temp/error" in "dble-1" should not exist
    Given delete file "/opt/dble/data.txt" on "dble-1"

  Scenario: test during execute load data, backend mysql disconnected, the logic of load data batch       #5
    Given execute admin cmd "kill @@load_data" success
    Given execute admin cmd "enable @@load_data_batch" success
    Given execute admin cmd "reload @@load_data.num=50000" success
    Given create local and server file "data1.txt" with "1000000" lines

    #for Multi-node-global table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                 | expect  | db      |
      | conn_0 | False   | drop table if exists schema1.test                                   | success | schema1 |
      | conn_0 | true    | create table schema1.test(id int,c int,d varchar(10),e varchar(10)) | success | schema1 |
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                                                               | db      |
      | conn_1 | true    | load data infile '/opt/dble/data1.txt' into table schema1.test fields terminated by ',' lines terminated by '\n' | schema1 |
    Given sleep "8" seconds
    Given restart mysql in "mysql-master1"
    Given sleep "15" seconds
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check path "/opt/dble/temp/error" in "dble-1" should not exist
    Then execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose | sql                       | expect           | db  |
      | conn_0 | false   | select count(*) from test | has{(1000000,),} | db1 |
      | conn_0 | true    | select count(*) from test | has{(1000000,),} | db2 |
    Given execute single sql in "mysql-master1" in "mysql" mode and save resultset in "A"
      | conn   | toClose | sql                       | expect              | db  |
      | conn_0 | true    | select count(*) from test | hasnot{(1000000,),} | db1 |
    Then get result of oscmd named "B" in "dble-1"
    """
    ls -l /opt/dble/temp/file|grep 'dn1.txt'|wc -l
    """
    Then Check "B" is calculated by "A" according to a certain relationship with "global_table"
    Given execute single sql in "mysql-master1" in "mysql" mode and save resultset in "C"
      | conn   | toClose | sql                       | expect              | db  |
      | conn_1 | true    | select count(*) from test | hasnot{(1000000,),} | db2 |
    Then get result of oscmd named "D" in "dble-1"
    """
    ls -l /opt/dble/temp/file|grep 'dn3.txt'|wc -l
    """
    Then Check "D" is calculated by "C" according to a certain relationship with "global_table"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                              | expect | db      |
      | conn_2 | true    | load data infile '/opt/dble/data1.txt' into table schema1.test fields terminated by ',' lines terminated by '\n' | success| schema1 |
    Then execute sql in "mysql-master1" in "mysql" mode
      | conn   | toClose | sql                       | expect           | db  |
      | conn_2 | false   | select count(*) from test | has{(1000000,),} | db1 |
      | conn_2 | true    | select count(*) from test | has{(1000000,),} | db2 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                       | expect           | db      |
      | conn_3 | true    | select count(*) from test | has{(1000000,),} | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should not exist

    #for Multi-node-sharding table
    Given execute admin cmd "kill @@load_data" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                          | expect  | db      |
      | conn_0 | False   | drop table if exists schema1.sharding_2_t1                                   | success | schema1 |
      | conn_0 | true    | create table schema1.sharding_2_t1(id int,c int,d varchar(10),e varchar(10)) | success | schema1 |
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                                                                        | db      |
      | conn_1 | true    | load data infile '/opt/dble/data1.txt' into table schema1.sharding_2_t1 fields terminated by ',' lines terminated by '\n' | schema1 |
    Given sleep "4" seconds
    Given restart mysql in "mysql-master1"
    Given sleep "10" seconds
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check path "/opt/dble/temp/error" in "dble-1" should not exist
    Then execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose | sql                                | expect           | db  |
      | conn_0 | true    | select count(*) from sharding_2_t1 | has{(500000,),} | db1 |
    Given execute single sql in "mysql-master1" in "mysql" mode and save resultset in "E"
      | conn   | toClose | sql                       | expect                       | db  |
      | conn_0 | true    | select count(*) from sharding_2_t1 | hasnot{(500000,),} | db1 |
    Then get result of oscmd named "F" in "dble-1"
    """
    ls -l /opt/dble/temp/file|grep 'dn1.txt'|wc -l
    """
    Then Check "F" is calculated by "E" according to a certain relationship with "sharding_table"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect | db      |
      | conn_2 | true    | load data infile '/opt/dble/data1.txt' into table schema1.sharding_2_t1 fields terminated by ',' lines terminated by '\n'  | success| schema1 |
    Then execute sql in "mysql-master1" in "mysql" mode
      | conn   | toClose | sql                                | expect           | db  |
      | conn_1 | true    | select count(*) from sharding_2_t1 | has{(500000,),} | db1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect           | db      |
      | conn_3 | true    | select count(*) from sharding_2_t1 | has{(1000000,),} | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should not exist

    #for single-node table
    Given execute admin cmd "kill @@load_data" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                          | expect  | db      |
      | conn_0 | False   | drop table if exists schema1.test1                                           | success | schema1 |
      | conn_0 | true    | create table schema1.test1(id int,c int,d varchar(10),e varchar(10))         | success | schema1 |
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                                                                | db      |
      | conn_1 | true    | load data infile '/opt/dble/data1.txt' into table schema1.test1 fields terminated by ',' lines terminated by '\n'  | schema1 |
    Given sleep "5" seconds
    Given restart mysql in "mysql-master1"
    Given sleep "10" seconds
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check path "/opt/dble/temp/error" in "dble-1" should not exist
    Given execute single sql in "mysql-master1" in "mysql" mode and save resultset in "G"
      | conn   | toClose | sql                        | expect                   | db  |
      | conn_0 | true    | select count(*) from test1 | hasnot{(1000000,),}      | db3 |
    Then get result of oscmd named "H" in "dble-1"
    """
    ls -l /opt/dble/temp/file|grep 'dn5.txt'|wc -l
    """
    Then Check "H" is calculated by "G" according to a certain relationship with "single_table"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                | expect | db      |
      | conn_2 | true    | load data infile '/opt/dble/data1.txt' into table schema1.test1 fields terminated by ',' lines terminated by '\n'  | success| schema1 |
    Given execute sql in "mysql-master1" in "mysql" mode
      | conn   | toClose | sql                        | expect                | db  |
      | conn_1 | true    | select count(*) from test1 | has{(1000000,),}      | db3 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                        | expect           | db      |
      | conn_2 | true    | select count(*) from test1 | has{(1000000,),} | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should not exist
    Given remove local and server file "data1.txt"

  Scenario: test with kill @@load_data                    #6
    Given execute oscmd in "dble-1"
    """
    rm -rf /opt/dble/data.txt
    """
    Given execute oscmd in "dble-1"
    """
    echo -e '1,1\n2,2\n3,3\n4,4\n5,5\n6,6\n7,7\n8,8\n9,9\n10,10\n11,11\n12,12\n13,13' > /opt/dble/data.txt
    """
    Given connect "dble-1" with user "test" in "dble-1" to execute sql
    """
    drop table if exists schema1.sharding_2_t1
    drop table if exists schema1.test
    drop table if exists schema1.test1
    create table schema1.sharding_2_t1(id int,c int)
    create table schema1.test(id int,c int)
    create table schema1.test1(id int,c int)
    """
    Then execute admin cmd "enable @@load_data_batch"
    Then execute admin cmd "reload @@load_data.num=2"

    #for Multi-node-sharding table
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,6/6,a/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect          | db
      | conn_0 | true    | load data infile '/opt/dble/data.txt' into table schema1.sharding_2_t1 fields terminated by ',' lines terminated by '\n'   | success         | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check path "/opt/dble/temp/error" in "dble-1" should exist
    Given sleep "3" seconds
    Given execute admin cmd "kill @@load_data" success
    Then check path "/opt/dble/temp" in "dble-1" should not exist
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,a/6,6/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect        | db      |
      | conn_1 | False   | load data infile '/opt/dble/data.txt' into table schema1.sharding_2_t1 fields terminated by ',' lines terminated by '\n'   | success       | schema1 |
      | conn_1 | true    | select * from schema1.sharding_2_t1                                                                                        | length{(22)}  | schema1 |
    Given execute admin cmd "kill @@load_data" success

    #for Multi-node-global table
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,6/6,a/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect          | db      |
      | conn_2 | true    | load data infile '/opt/dble/data.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'            | success         | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check path "/opt/dble/temp/error" in "dble-1" should exist
    Given sleep "3" seconds
    Given execute admin cmd "kill @@load_data" success
    Then check path "/opt/dble/temp" in "dble-1" should not exist
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,a/6,6/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect            | db      |
      | conn_3 | False   | load data infile '/opt/dble/data.txt' into table schema1.test fields terminated by ',' lines terminated by '\n'            | success           | schema1 |
      | conn_3 | true    | select * from schema1.test                                                                                                 | length{(17)}      | schema1 |
    Given execute admin cmd "kill @@load_data" success

    #for single-node table
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,6/6,a/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                         | expect          | db      |
      | conn_4 | true    | load data infile '/opt/dble/data.txt' into table schema1.test1 fields terminated by ',' lines terminated by '\n'            | success         | schema1 |
    Then check path "/opt/dble/temp/file" in "dble-1" should exist
    Then check path "/opt/dble/temp/error" in "dble-1" should exist
    Given sleep "3" seconds
    Given execute admin cmd "kill @@load_data" success
    Then check path "/opt/dble/temp" in "dble-1" should not exist
    Given update file content "/opt/dble/data.txt" in "dble-1" with sed cmds
    """
    6s/6,a/6,6/
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                        | expect          | db      |
      | conn_5 | False   | load data infile '/opt/dble/data.txt' into table schema1.test1 fields terminated by ',' lines terminated by '\n'           | success         | schema1 |
      | conn_5 | False   | select * from test1                                                                                                        | length{(17)}    | schema1 |
      | conn_5 | False   | drop table if exists schema1.sharding_2_t1                                                                                 | success         | schema1 |
      | conn_5 | False   | drop table if exists schema1.test                                                                                          | success         | schema1 |
      | conn_5 | true    | drop table if exists schema1.test1                                                                                         | success         | schema1 |
    Given execute admin cmd "kill @@load_data" success
    Given delete file "/opt/dble/data.txt" on "dble-1"
