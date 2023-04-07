# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by mayingle at 2021/10/25

Feature: dble support execute set @@variables=true/false test;
  """
  autocommit,
  big_tables,
  end_markers_in_json,
  explicit_defaults_for_timestamp,
  foreign_key_checks,
  keep_files_on_create,
  low_priority_updates,
#  new: for NDB Cluster,
  old_alter_table,
#  pseudo_slave_mode: This system variable is for internal server use,
#  query_cache_wlock_invalidate: is removed in MySQL 8.0. ,
  session_track_schema,
  session_track_state_change,
  show_create_table_verbosity,
  show_old_temporals,
  sql_auto_is_null,
  sql_big_selects,
  sql_buffer_result,
  sql_log_off,
  sql_notes,
  sql_quote_show_create,
  sql_safe_updates,
  sql_warnings，
  transaction_read_only，
  tx_read_only，
  unique_checks，
  updatable_views_with_limit
  """

  Scenario: dble support execute set autocommit test #1
    #github issue #2873
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                               | expect       | db      |
      | conn_0 | False    | set autocommit=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "autocommit";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set autocommit=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set autocommit=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set autocommit=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set autocommit=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set autocommit=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set autocommit=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set autocommit=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set autocommit=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set autocommit=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set autocommit=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set autocommit=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set autocommit=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@autocommit;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set autocommit=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "autocommit";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@autocommit;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set big_tables test #2
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                               | expect       | db      |
      | conn_0 | False    | set big_tables=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "big_tables";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set big_tables=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set big_tables=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set big_tables=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set big_tables=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set big_tables=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set big_tables=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set big_tables=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set big_tables=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set big_tables=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set big_tables=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set big_tables=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set big_tables=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@big_tables;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set big_tables=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "big_tables";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@big_tables;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set end_markers_in_json test #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                        | expect       | db      |
      | conn_0 | False    | set end_markers_in_json=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "end_markers_in_json";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@end_markers_in_json;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set end_markers_in_json=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "end_markers_in_json";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@end_markers_in_json;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set explicit_defaults_for_timestamp test #4
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                    | expect       | db      |
      | conn_0 | False    | set explicit_defaults_for_timestamp=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "explicit_defaults_for_timestamp";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@explicit_defaults_for_timestamp;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set explicit_defaults_for_timestamp=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "explicit_defaults_for_timestamp";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@explicit_defaults_for_timestamp;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set foreign_key_checks test #5
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                       | expect       | db      |
      | conn_0 | False    | set foreign_key_checks=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "foreign_key_checks";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@foreign_key_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set foreign_key_checks=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "foreign_key_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@foreign_key_checks;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set keep_files_on_create test #6
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                         | expect       | db      |
      | conn_0 | False    | set keep_files_on_create=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "keep_files_on_create";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@keep_files_on_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set keep_files_on_create=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "keep_files_on_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@keep_files_on_create;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set low_priority_updates test #7
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                         | expect       | db      |
      | conn_0 | False    | set low_priority_updates=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "low_priority_updates";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@low_priority_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set low_priority_updates=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "low_priority_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@low_priority_updates;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set old_alter_table test #8
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                    | expect       | db      |
      | conn_0 | False    | set old_alter_table=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "old_alter_table";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@old_alter_table;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set old_alter_table=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "old_alter_table";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@old_alter_table;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set session_track_schema test #9
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                         | expect       | db      |
      | conn_0 | False    | set session_track_schema=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "session_track_schema";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_schema;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_schema=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_schema";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@session_track_schema;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set session_track_state_change test #10
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                               | expect       | db      |
      | conn_0 | False    | set session_track_state_change=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "session_track_state_change";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@session_track_state_change;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set session_track_state_change=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "session_track_state_change";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@session_track_state_change;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set show_create_table_verbosity test #11
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                | expect       | db      |
      | conn_0 | False    | set show_create_table_verbosity=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "show_create_table_verbosity";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_create_table_verbosity;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_create_table_verbosity=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "show_create_table_verbosity";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@show_create_table_verbosity;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set show_old_temporals test #12
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                       | expect       | db      |
      | conn_0 | False    | set show_old_temporals=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "show_old_temporals";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@show_old_temporals;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set show_old_temporals=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "show_old_temporals";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@show_old_temporals;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set sql_auto_is_null test #13
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                     | expect       | db      |
      | conn_0 | False    | set sql_auto_is_null=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "sql_auto_is_null";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_auto_is_null;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_auto_is_null=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_auto_is_null";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@sql_auto_is_null;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set sql_big_selects test #14
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                    | expect       | db      |
      | conn_0 | False    | set sql_big_selects=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "sql_big_selects";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_big_selects;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_big_selects=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_big_selects";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@sql_big_selects;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set sql_buffer_result test #15
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                      | expect       | db      |
      | conn_0 | False    | set sql_buffer_result=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "sql_buffer_result";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_buffer_result;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_buffer_result=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_buffer_result";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@sql_buffer_result;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set sql_log_off test #16
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                | expect       | db      |
      | conn_0 | False    | set sql_log_off=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "sql_log_off";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_log_off;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_log_off=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_log_off";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@sql_log_off;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set sql_notes test #17
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                              | expect       | db      |
      | conn_0 | False    | set sql_notes=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "sql_notes";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_notes=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_notes=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_notes=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_notes=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_notes=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_notes=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_notes=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_notes=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_notes=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_notes=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_notes=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_notes=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_notes;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_notes=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_notes";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@sql_notes;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set sql_quote_show_create test #18
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                          | expect       | db      |
      | conn_0 | False    | set sql_quote_show_create=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "sql_quote_show_create";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_quote_show_create;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_quote_show_create=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_quote_show_create";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@sql_quote_show_create;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set sql_safe_updates test #19
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                     | expect       | db      |
      | conn_0 | False    | set sql_safe_updates=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "sql_safe_updates";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_safe_updates;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_safe_updates=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_safe_updates";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@sql_safe_updates;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set sql_warnings test #20
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                 | expect       | db      |
      | conn_0 | False    | set sql_warnings=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "sql_warnings";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@sql_warnings;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set sql_warnings=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "sql_warnings";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@sql_warnings;                              | has{((0,),)} | schema1 |

@skip
  ##不适合于3.21.02
  Scenario: dble support execute set transaction_read_only test #21
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                          | expect       | db      |
      | conn_0 | False    | set transaction_read_only=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "transaction_read_only";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@transaction_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set transaction_read_only=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "transaction_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@transaction_read_only;                              | has{((0,),)} | schema1 |

 @skip
  ##不适合于3.21.02
   @use.with_mysql_version=5.7
  Scenario: dble support execute set tx_read_only test #22.1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                 | expect       | db      |
      | conn_0 | False    | set tx_read_only=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "tx_read_only";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@tx_read_only;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set tx_read_only=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "tx_read_only";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@tx_read_only;                              | has{((0,),)} | schema1 |


  Scenario: dble support execute set unique_checks test #23
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                  | expect       | db      |
      | conn_0 | False    | set unique_checks=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "unique_checks";                 | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set unique_checks=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set unique_checks=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set unique_checks=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set unique_checks=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set unique_checks=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set unique_checks=ON;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set unique_checks=OFF;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set unique_checks=On;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set unique_checks=Off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set unique_checks=on;                                | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set unique_checks=off;                               | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((0,),)} | schema1 |
      | conn_0 | False    | set unique_checks=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'ON'}    | schema1 |
      | conn_0 | False    | select @@unique_checks;                              | has{((1,),)} | schema1 |
      | conn_0 | False    | set unique_checks=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "unique_checks";                | hasStr{'OFF'}   | schema1 |
      | conn_0 | True     | select @@unique_checks;                              | has{((0,),)} | schema1 |


Scenario: dble support execute set updatable_views_with_limit test #24
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                               | expect       | db      |
      | conn_0 | False    | set updatable_views_with_limit=1;                                 | success      | schema1 |
      | conn_0 | False    | show variables like "updatable_views_with_limit";                 | hasStr{'YES'}   | schema1 |
      | conn_0 | False    | select @@updatable_views_with_limit;                              | hasStr{'YES'}   | schema1 |
      | conn_0 | False    | set updatable_views_with_limit=false;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "updatable_views_with_limit";                | hasStr{'NO'}   | schema1 |
      | conn_0 | False    | select @@updatable_views_with_limit;                              | hasStr{'NO'}   | schema1 |
      | conn_0 | False    | set updatable_views_with_limit=TRUE;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "updatable_views_with_limit";                | hasStr{'YES'}    | schema1 |
      | conn_0 | False    | select @@updatable_views_with_limit;                              | hasStr{'YES'}   | schema1 |
      | conn_0 | False    | set updatable_views_with_limit=FALSE;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "updatable_views_with_limit";                | hasStr{'NO'}   | schema1 |
      | conn_0 | False    | select @@updatable_views_with_limit;                              | hasStr{'NO'}   | schema1 |
      | conn_0 | False    | set updatable_views_with_limit=True;                              | success      | schema1 |
      | conn_0 | False    | show  variables like "updatable_views_with_limit";                | hasStr{'YES'}    | schema1 |
      | conn_0 | False    | select @@updatable_views_with_limit;                              | hasStr{'YES'}   | schema1 |
      | conn_0 | False    | set updatable_views_with_limit=False;                             | success      | schema1 |
      | conn_0 | False    | show  variables like "updatable_views_with_limit";                | hasStr{'NO'}   | schema1 |
      | conn_0 | False    | select @@updatable_views_with_limit;                              | hasStr{'NO'}   | schema1 |
      | conn_0 | False    | set updatable_views_with_limit=1;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "updatable_views_with_limit";                | hasStr{'YES'}    | schema1 |
      | conn_0 | False    | select @@updatable_views_with_limit;                              | hasStr{'YES'}   | schema1 |
      | conn_0 | False    | set updatable_views_with_limit=0;                                 | success      | schema1 |
      | conn_0 | False    | show  variables like "updatable_views_with_limit";                | hasStr{'NO'}   | schema1 |
      | conn_0 | True     | select @@updatable_views_with_limit;                              | hasStr{'NO'}   | schema1 |


