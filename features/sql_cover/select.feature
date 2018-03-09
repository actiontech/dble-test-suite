Feature: basic sql translate/transmission correct, seperate read/write statements, read load balance

    Scenario Outline:#1 check read-write-split work fine and slaves load balance
        Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
        Given clear dirty data yield by sql

        Examples:Types
          | filename                                  |
          | select/expression.sql                     |
          | select/expression_global.sql              |
          | select/expression_no_sharding.sql         |
          | select/join.sql                           |
          | select/join_global.sql                    |
          | select/join_no_er.sql                     |
          | select/join_no_sharding.sql               |
          | select/reference.sql                      |
          | select/reference_global.sql               |
          | select/reference_no_er.sql                |
          | select/reference_no_sharding.sql          |
          | select/select.sql                         |
          | select/select_global.sql                  |
          | select/select_global_old.sql              |
          | select/select_join_sharding.sql           |
          | select/select_no_sharding.sql             |
          | select/select_sharding.sql                |
          | select/subquery.sql                       |
          | select/subquery_global.sql                |
          | select/subquery_no_er.sql                 |
          | select/subquery_no_sharding.sql           |
