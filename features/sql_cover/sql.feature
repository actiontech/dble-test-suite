Feature: basic sql translate/transmission correct, seperate read/write statements, read load balance

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
          | select/subquery.sql                         |
          | select/subquery_global.sql                  |
          | select/subquery_global_noshard.sql          |
          | select/subquery_no_er.sql                   |
          | select/subquery_no_sharding.sql             |
          | select/subquery_shard_global.sql            |
          | select/subquery_shard_noshard.sql           |

    @current
    Scenario Outline:#3 check read-write-split work fine and slaves load balance transaction
        Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
        Given clear dirty data yield by sql

        Examples:Types
          | filename                                  |
          | transaction/D_langues.sql                 |
          | transaction/lock.sql                      |
          | transaction/t_langues.sql                 |
          | transaction/transaction.sql               |


    Scenario: #3 compare new generated results is same with the standard ones
        When compare results with the standard results

