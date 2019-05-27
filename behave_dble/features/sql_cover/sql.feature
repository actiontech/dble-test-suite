# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: basic sql translate/transmission correct, seperate read/write statements, read load balance

    @CRITICAL
    Scenario Outline:#1 check read-write-split work fine and slaves load balance
        Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
        Given clear dirty data yield by sql

        Examples:Types
          | filename                                  |
          | syntax/alter_table.sql                    |
          | syntax/character.sql                      |
          | syntax/create_index.sql                   |
          | syntax/create_table_definition_syntax.sql |
          | syntax/create_table_type.sql              |
          | syntax/data_types.sql                     |
          | syntax/delete.sql                         |
          | syntax/identifiers.sql                    |
          | syntax/insert_on_duplicate_key.sql        |
          | syntax/insert_syntax.sql                  |
          | syntax/insert_value.sql                   |
          | syntax/replace.sql                        |
          | syntax/reserved_words.sql                 |
          | syntax/set_names_character.sql            |
          | syntax/set_test.sql                       |
          | syntax/set_user_var.sql                   |
          | syntax/show.sql                           |
          | syntax/sysfunction1.sql                   |
          | syntax/sysfunction2.sql                   |
          | syntax/sysfunction3.sql                   |
          | syntax/truncate.sql                       |
          | syntax/update_syntax.sql                  |
          | syntax/prepare.sql                        |
          | syntax/view.sql                           |
          | bugs/bug.sql                              |

    Scenario Outline:#2 check read-write-split work fine and slaves load balance
        Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
        Given clear dirty data yield by sql

        Examples:Types
          | filename                                    |
          | select/expression.sql                       |
          | select/expression_global.sql                |
          | select/expression_no_sharding.sql           |
          | select/join.sql                             |
          | select/join_global.sql                      |
          | select/join_global_no_sharding.sql          |
          | select/join_global_sharding.sql             |
          | select/join_no_er.sql                       |
          | select/join_no_sharding.sql                 |
          | select/join_shard_noshard.sql               |
          | select/reference.sql                        |
          | select/reference_global.sql                 |
          | select/reference_global_noshard.sql         |
          | select/reference_no_er.sql                  |
          | select/reference_no_sharding.sql            |
          | select/reference_shard_global.sql           |
          | select/reference_shard_noshard.sql          |
          | select/select.sql                           |
          | select/select_global.sql                    |
          | select/select_global_old.sql                |
          | select/select_join_sharding.sql             |
          | select/select_no_sharding.sql               |
          | select/select_sharding.sql                  |
          | select/subquery_dev.sql                     |
          | select/subquery.sql                         |
          | select/subquery_global.sql                  |
          | select/subquery_global_noshard.sql          |
          | select/subquery_no_er.sql                   |
          | select/subquery_no_sharding.sql             |
          | select/subquery_shard_global.sql            |
          | select/subquery_shard_noshard.sql           |


    Scenario Outline:#3 check read-write-split work fine and slaves load balance transaction
        Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
        Given clear dirty data yield by sql

        Examples:Types
          | filename                                  |
          | transaction/D_langues.sql                 |
          | transaction/lock.sql                      |
          | transaction/t_langues.sql                 |
          | transaction/transaction.sql               |

    @current
    Scenario Outline:cover empty line in file, no line in file, chinese character in file, special character in file for load data [local] infile ...#4
      #1.1 no line in file
      Given create local and server file "test1.txt" and fill with text
      """
      """
      #1.2 empty line in file
      Given create local and server file "test2.txt" and fill with text
      """

      """
      #1.3 chinese character and special character
      Given create local and server file "test3.txt" and fill with text
      """
      1,aaa,0,0,3.1415,20180905121530
      2,中,1,1,-3.1415,20180905121530
      3,$%'";:@#^&*_+-=|\<.>/?`~,5,0,0.0010,20180905
      """
      #1.4 with replace into in load data
      Given create local and server file "test4.txt" and fill with text
      """
      1,1,,
      """
      #1.5 abnormal test for lack column
      Given create local and server file "test5.txt" and fill with text
      """
      4,
      """
#      ,1,a,20181018163000,20181018,163000,0,0
#      b,,b,20181018163000,20181018,163000,0,0
#      c,3,,20181018163000,20181018,163000,0,0
#      d,4,d,,20181018,163000,0,0b00
#      e,5,e,20181018163000,,163000,0,0b00
#      f,6,f,20181018163000,20181018,,0,0b00
#      g,7,g,20181018163000,20181018,163000,,0
#      h,8,h,20181018163000,20181018,163000,0,
#
#      ,,i,20181018163000,20181018,163000,0,1
#      ,,,20181018163000,20181018,163000,0,1
#      ,,,,20181018,163000,0,0b00
#      ,,,,,163000,0,0b00
#      ,,,,,,0,0b00
#      ,,,,,,,0b00
#      ,,,,,,,
#      ,,,,,,
#      ,,,,,
#      ,,,,
#      ,,,
#      ,,
#      ,
#
#      j,9,j,20181018163000,20181018,163000,0,1
#      k,10,k,20181018163000,20181018,163000,0,
#      l,11,l,20181018163000,20181018,163000,
#      m,12,m,20181018163000,20181018,
#      o,13,o,20181018163000,
#      p,14,p,
#      q,15,
#      r,
#
#      s,16,s,20181018163000,20181018,163000,0
#      t,17,t,20181018163000,20181018,163000
#      u,18,u,20181018163000,20181018
#      v,19,v,20181018163000
#      w,20,w
#      x,21
#      y
#
#
#      z,22,z,20181018163000,20181018,163000,0,0
#      aa,0x17,1,20181018163000,20181018,163000,0,0
#
#
#      """
      Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
      Given clear dirty data yield by sql
      Given remove local and server file "test1.txt"
      Given remove local and server file "test2.txt"
      Given remove local and server file "test3.txt"
      Given remove local and server file "test4.txt"
      Given remove local and server file "test5.txt"

      Examples:Types
        | filename                                    |
        | syntax/loaddata.sql                         |

    Scenario: #5 compare new generated results is same with the standard ones
        When compare results with the standard results in "std_result"

