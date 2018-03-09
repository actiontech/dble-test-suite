# Created by MAOFEI at 2017/9/25
Feature: test transaction
  # Enter feature description here
    Scenario Outline:
        Then execute sql in "<filename>" to check manager work fine
        Examples:Types
          | filename                           |
          | manager/manager.sql                |