# -*- coding=utf-8 -*-
@setup
Feature: mixed type tables sql cover test
"""
Given rm old logs "sql_cover_mixed" if exists
Given reset replication and none system databases
"""
    Scenario Outline:sql cover for mixed table types #2
      Given set sql cover log dir "sql_cover_mixed"
      Then execute sql in file "<filename>"
      Given clear dirty data yield by sql

      Examples:Types
        | filename                                               |
        | sqls_mixed/select/join_different_rules_shardings.sql   |
        | sqls_mixed/select/join_global_nosharding.sql           |
        | sqls_mixed/select/join_global_sharding.sql             |
        | sqls_mixed/select/join_global_sharding_nosharding.sql  |
        | sqls_mixed/select/join_no_er.sql                       |
        | sqls_mixed/select/join_sharding_nosharding.sql         |
        | sqls_mixed/select/join_shardings.sql                   |
        | sqls_mixed/select/subquery.sql                         |
        | sqls_mixed/select/subquery_dev.sql                     |
        | sqls_mixed/select/subquery_global_noshard.sql          |
        | sqls_mixed/select/subquery_no_er.sql                   |
        | sqls_mixed/select/subquery_shard_global.sql            |
        | sqls_mixed/select/subquery_shard_noshard.sql           |
        | sqls_mixed/syntax/character.sql                        |
        | sqls_mixed/syntax/create_index.sql                     |
        | sqls_mixed/syntax/identifiers.sql                      |
        | sqls_mixed/syntax/partition.sql                        |
        | sqls_mixed/syntax/select_literals.sql                  |
        | sqls_mixed/syntax/set_names_character_mixed.sql        |
        | sqls_mixed/syntax/set_server_var.sql                   |
        | sqls_mixed/syntax/set_user_var.sql                     |
        | sqls_mixed/syntax/sysfunction1.sql                     |
        | sqls_mixed/syntax/sysfunction2.sql                     |
        | sqls_mixed/syntax/sysfunction3.sql                     |
        | sqls_mixed/bugs/bug.sql                                |

  @current
  Scenario: #5 compare new generated results is same with the standard ones
        When compare results in "sql_cover_mixed" with the standard results in "std_sql_cover_mixed"