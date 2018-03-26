Feature: basic sql translate/transmission correct, seperate read/write statements, read load balance

    Scenario Outline:#1 check read-write-split work fine and slaves load balance
        Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
        Given clear dirty data yield by sql

        Examples:Types
          | filename                                  |
#          | syntax/alter_table.sql                    |
#          | syntax/character.sql                      |
#          | syntax/create_index.sql                   |
#          | syntax/create_table_definition_syntax.sql |
#          | syntax/create_table_type.sql              |
#          | syntax/data_types.sql                     |
#          | syntax/delete.sql                         |
#          | syntax/insert_on_duplicate_key.sql        |
#          | syntax/insert_syntax.sql                  |
#          | syntax/insert_value.sql                   |
#          | syntax/replace.sql                        |
#          | syntax/reserved_words.sql                 |
#          | syntax/set_names_character.sql            |
#          | syntax/set_test.sql                       |
#          | syntax/set_user_var.sql                   |
#          | syntax/show.sql                           |
          | syntax/sysfunction1.sql                   |
          | syntax/sysfunction2.sql                   |
          | syntax/sysfunction3.sql                   |
          | syntax/truncate.sql                       |
          | syntax/update_syntax.sql                  |




