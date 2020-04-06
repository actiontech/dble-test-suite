# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yexiaoli at 2018/11/1
Feature: queries to mysql default database send by  Navicat Premium 12, dble will mock a resultset to support it

  @NORMAL
  Scenario: test navicat used sqls support when connect to dble #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                              | expect        | db     |
      | conn_0 | False   | SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'schema1' ORDER BY TABLE_SCHEMA, TABLE_TYPE                                 | length{(0)}  | schema1 |
      | conn_0 | False   | SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'schema1' ORDER BY TABLE_SCHEMA,TABLE_NAME                 | length{(0)}  | schema1 |
      | conn_0 | False   | SELECT DISTINCT ROUTINE_SCHEMA, ROUTINE_NAME, PARAMS.PARAMETER FROM information_schema.ROUTINES LEFT JOIN ( SELECT SPECIFIC_SCHEMA, SPECIFIC_NAME, GROUP_CONCAT(CONCAT(DATA_TYPE, ' ', PARAMETER_NAME) ORDER BY ORDINAL_POSITION SEPARATOR ', ') PARAMETER, ROUTINE_TYPE FROM information_schema.PARAMETERS GROUP BY SPECIFIC_SCHEMA, SPECIFIC_NAME, ROUTINE_TYPE ) PARAMS ON ROUTINES.ROUTINE_SCHEMA = PARAMS.SPECIFIC_SCHEMA AND ROUTINES.ROUTINE_NAME = PARAMS.SPECIFIC_NAME AND ROUTINES.ROUTINE_TYPE = PARAMS.ROUTINE_TYPE WHERE ROUTINE_SCHEMA = 'schema1' ORDER BY ROUTINE_SCHEMA | length{(0)} | schema1 |
      | conn_0 | False   | SELECT TABLE_NAME, CHECK_OPTION, IS_UPDATABLE, SECURITY_TYPE, DEFINER FROM information_schema.VIEWS WHERE TABLE_SCHEMA = 'schema1' ORDER BY TABLE_NAME ASC                | length{(0)}   | schema1 |
      | conn_0 | False   | SELECT * FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = 'schema1' ORDER BY ROUTINE_NAME                                                                                    | length{(0)}   | schema1 |
      | conn_0 | True    | SELECT DISTINCT ROUTINE_SCHEMA, ROUTINE_NAME, PARAMS.PARAMETER FROM information_schema.ROUTINES LEFT JOIN ( SELECT SPECIFIC_SCHEMA, SPECIFIC_NAME, GROUP_CONCAT(CONCAT(DATA_TYPE, ' ', PARAMETER_NAME) ORDER BY ORDINAL_POSITION SEPARATOR ', ') PARAMETER, ROUTINE_TYPE FROM information_schema.PARAMETERS GROUP BY SPECIFIC_SCHEMA, SPECIFIC_NAME, ROUTINE_TYPE ) PARAMS ON ROUTINES.ROUTINE_SCHEMA = PARAMS.SPECIFIC_SCHEMA AND ROUTINES.ROUTINE_NAME = PARAMS.SPECIFIC_NAME AND ROUTINES.ROUTINE_TYPE = PARAMS.ROUTINE_TYPE WHERE ROUTINE_SCHEMA = 'schema1' ORDER BY ROUTINE_SCHEMA| length{(0)} | schema1 |