# Created by MAOFEI at 2017/9/25
Feature: test transaction
  # Enter feature description here

    Scenario Outline:
        Then Then execute sql in "<filename>" to check tansaction work fine

        Examples:Types
          | filename                                  |
          | transaction/D_langues.sql                 |
          | transaction/lock.sql                      |
          | transaction/t_langues.sql                 |
          | transaction/transaction.sql               |