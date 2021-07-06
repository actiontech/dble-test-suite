# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/4/30

Feature: server side cursor test DBLE0REQ-764

  Scenario: check cursor parameter in bootstrap.cnf - default values #1
    # check default values
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "cursor_rs1"
      | sql             |
      | show @@sysparam |
    Then check resultset "cursor_rs1" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1 |
      | maxHeapTableSize         | 4096B         |
      | heapTableBufferChunkSize | 4096B         |
      | enableCursor             | false         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "cursor_rs2"
      | conn   | toClose | sql                                                                                                                               | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name like '%heapTable%' or variable_name = 'enableCursor' | dble_information |
    Then check resultset "cursor_rs2" has lines with following column values
      | variable_name-0          | variable_value-1 |
      | maxHeapTableSize         | 4096B            |
      | heapTableBufferChunkSize | 4096B            |
      | enableCursor             | false            |

  Scenario: check cursor parameter in bootstrap.cnf - illegal values #2
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DheapTableBufferChunkSize/d
    $a -DheapTableBufferChunkSize=-1
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ heapTableBufferChunkSize \] '-1' in bootstrap.cnf is illegal, it must be a multiple of property 'bufferPoolChunkSize' and great than 0.
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DheapTableBufferChunkSize=-1/c -DheapTableBufferChunkSize=1234
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ heapTableBufferChunkSize \] '1234' in bootstrap.cnf is illegal, it must be a multiple of property 'bufferPoolChunkSize' and great than 0.
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DmaxHeapTableSize/d
    $a -DmaxHeapTableSize=-1
    /-DenableCursor/d
    $a -DenableCursor=123
    """
    Then restart dble in "dble-1" failed for
  """
    Property \[ maxHeapTableSize \] '-1' in bootstrap.cnf is illegal, you may need use the default value 4096 replaced
    Property \[ enableCursor \] '123' data type should be boolean
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DmaxHeapTableSize=-1/c -DmaxHeapTableSize=abc
    /-DheapTableBufferChunkSize=1234/c -DheapTableBufferChunkSize=abc
    /-DenableCursor=123/c -DenableCursor=abc
    """
    Then restart dble in "dble-1" failed for
    """
    property [[] maxHeapTableSize []] 'abc' data type should be int
    property [[] heapTableBufferChunkSize []] 'abc' data type should be class java.lang.Integer
    property [[] enableCursor []] 'abc' data type should be boolean
    """

  Scenario: check cursor parameter in bootstrap.cnf - valid values #3
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DbufferPoolChunkSize=/d
    $a -DbufferPoolChunkSize=512
    /-DmaxHeapTableSize=/d
    $a -DmaxHeapTableSize=1000
    /-DheapTableBufferChunkSize=/d
    $a -DheapTableBufferChunkSize=1024
    /-DenableCursor=/d
    $a -DenableCursor=FALSE
    """
    Then restart dble in "dble-1" success

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "cursor_rs3"
      | sql             |
      | show @@sysparam |
    Then check resultset "cursor_rs3" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1 |
      | maxHeapTableSize         | 1000B         |
      | heapTableBufferChunkSize | 1024B         |
      | bufferPoolChunkSize      | 512B          |
      | enableCursor             | false         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "cursor_rs4"
      | conn   | toClose | sql                                                                                                                                                                    | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name like '%heapTable%' or variable_name='bufferPoolChunkSize' or variable_name='enableCursor' | dble_information |
    Then check resultset "cursor_rs4" has lines with following column values
      | variable_name-0          | variable_value-1 |
      | maxHeapTableSize         | 1000B            |
      | heapTableBufferChunkSize | 1024B            |
      | bufferPoolChunkSize      | 512B             |
      | enableCursor             | false            |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DmaxHeapTableSize=1000/c -DmaxHeapTableSize=0
    /-DheapTableBufferChunkSize=1024/c -DheapTableBufferChunkSize=2048
    /-DbufferPoolChunkSize=512/c -DbufferPoolChunkSize=2048
    /-DenableCursor=FALSE/c -DenableCursor=true
    """
    Then restart dble in "dble-1" success

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "cursor_rs5"
      | sql             |
      | show @@sysparam |
    Then check resultset "cursor_rs5" has lines with following column values
      | PARAM_NAME-0             | PARAM_VALUE-1 |
      | maxHeapTableSize         | 0B            |
      | heapTableBufferChunkSize | 2048B         |
      | bufferPoolChunkSize      | 2048B         |
      | enableCursor             | true          |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "cursor_rs6"
      | conn   | toClose | sql                                                                                                                                                                    | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name like '%heapTable%' or variable_name='bufferPoolChunkSize' or variable_name='enableCursor' | dble_information |
    Then check resultset "cursor_rs6" has lines with following column values
      | variable_name-0          | variable_value-1 |
      | maxHeapTableSize         | 0B               |
      | heapTableBufferChunkSize | 2048B            |
      | bufferPoolChunkSize      | 2048B            |
      | enableCursor             | true             |
