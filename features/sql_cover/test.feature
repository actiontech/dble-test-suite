Feature: basic sql translate/transmission correct, seperate read/write statements, read load balance

 Scenario Outline:#3 check read-write-split work fine and slaves load balance transaction
        Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
        Given clear dirty data yield by sql

        Examples:Types
          | filename                                  |
          | transaction/D_langues.sql                 |
          | transaction/lock.sql                      |
          | transaction/t_langues.sql                 |
          | transaction/transaction.sql               |

