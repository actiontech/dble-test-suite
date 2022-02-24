# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
@setup
Feature: sharding table sql cover test
"""
Given rm old logs "sql_cover_sharding" if exists
Given reset replication and none system databases
Given reset views in "dble-1" if exists
"""


   Scenario:cover empty line in file, no line in file, chinese character in file, special character in file for sql syntax: load data [local] infile ...#1
     Given set sql cover log dir "sql_cover_sharding"
     Given prepare loaddata.sql data for sql test
     Then execute sql in file "sqls_util/syntax/loaddata.sql"
     Given clear dirty data yield by sql
     Given clean loaddata.sql used data

    Scenario Outline:sql cover for sharding table #2
      Given set sql cover log dir "sql_cover_sharding"
      Then execute sql in file "<filename>"
      Given clear dirty data yield by sql

      Examples:Types
        | filename                                              |
        | sqls_util/select/expression.sql                       |
        | sqls_util/select/reference.sql                        |
        | sqls_util/select/select.sql                           |
        | sqls_util/syntax/aggregate.sql                        |
        | sqls_util/syntax/alter_table.sql                      |
        | sqls_util/syntax/create_table_definition.sql          |
        | sqls_util/syntax/data_types_1.sql                     |
        | sqls_util/syntax/data_types_2.sql                     |
        | sqls_util/syntax/delete.sql                           |
        | sqls_util/syntax/identifiers_util.sql                 |
        | sqls_util/syntax/insert.sql                           |
        | sqls_util/syntax/insert_on_duplicate_key.sql          |
        | sqls_util/syntax/insert_value.sql                     |
        | sqls_util/syntax/prepare.sql                          |
        | sqls_util/syntax/replace.sql                          |
        | sqls_util/syntax/reserved_words.sql                   |
        | sqls_util/syntax/set_names_character.sql              |
        | sqls_util/syntax/set_server_var_util.sql              |
        | sqls_util/syntax/show.sql                             |
        | sqls_util/syntax/show_dble.sql                        |
        | sqls_util/syntax/sys_function_util.sql                |
        | sqls_util/syntax/truncate.sql                         |
        | sqls_util/syntax/union.sql                            |
        | sqls_util/syntax/update_syntax.sql                    |
        | sqls_util/syntax/view.sql                             |
        | sqls_util/transaction/lock.sql                        |
        | sqls_util/transaction/trx_ddl_dml.sql                 |
        | sqls_util/transaction/trx_isolation.sql               |
        | sqls_util/transaction/trx_syntax.sql                  |
        | sqls_util/transaction/trx_savepoint.sql               |
        | sqls_util/dev_dealed/cross_db.sql                     |
        | special_sharding/select/select_sharding.sql           |
        | special_sharding/select/er_sharding.sql               |
        | special_sharding/syntax/set_user_var_util.sql         |

    Scenario: #5 compare new generated results is same with the standard ones
        When compare results in "sql_cover_sharding" with the standard results in "std_sql_cover_sharding"