

Feature: test_sql_executing_feature

  Scenario Outline:sql execute 
  #循环执行下列步骤
  
    Given execute sqls in file "<sql_files>"

    Examples:
      |sql_files|
      |test.sql|