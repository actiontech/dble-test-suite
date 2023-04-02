

Feature: test_sql_executing_feature

    Scenario Outline:sql execute 
  #循环执行下列步骤
  
      Given execute sqls in file "<sql_files>"

      Examples:
          |sql_files|
          |character.sql|
          |maxscale/select_for_var_set.sql   |
          |maxscale/set_autocommit_disabled.sql         |
          |maxscale/test_after_autocommit_disabled.sql  |
          |maxscale/test_autocommit_disabled1.sql       |
          |maxscale/test_autocommit_disabled1b.sql      |
          |maxscale/test_autocommit_disabled2.sql       |
          |maxscale/test_autocommit_disabled3.sql       |
          #此系列 有一些语法是否适配？
        #   |maxscale/test_implicit_commit1.sql           |
        #   |maxscale/test_implicit_commit2.sql           |
        #   | maxscale/test_implicit_commit3.sql           |
        #   | maxscale/test_implicit_commit4.sql           |
        #   | maxscale/test_implicit_commit5.sql           |
        #   | maxscale/test_implicit_commit6.sql           |
        #   | maxscale/test_implicit_commit7.sql           |
          | maxscale/test_sescmd.sql                     |
          | maxscale/test_sescmd2.sql                    |
          | maxscale/test_sescmd3.sql                    |
          | maxscale/test_temporary_table.sql            |
          | maxscale/test_transaction_routing1.sql       |
          | maxscale/test_transaction_routing2.sql       |
          | maxscale/test_transaction_routing2b.sql      |
          | maxscale/test_transaction_routing3.sql       |
          | maxscale/test_transaction_routing3b.sql      |
          | maxscale/test_transaction_routing4.sql       |
          | maxscale/test_transaction_routing4b.sql      |
