Feature: basic sql translate/transmission correct, seperate read/write statements, read load balance

    Scenario Outline:#1 check read-write-split work fine and slaves load balance
        Then execute sql in "<filename>" to check read-write-split work fine and log dest slave
        Given clear dirty data yield by sql

        Examples:Types
          | filename                                  |
          | syntax/sysfunction1.sql                   |