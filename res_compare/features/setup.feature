# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Feature: do nothing but reset dble with command line config

    # @skip_restart
    # Scenario: do setups
@setup
Feature: Deploy DBLE test environment

  @Initialize_mysql @skip_restart
  Scenario: Initialize the MySQL
    Given I clean mysql deploy environment
    Given I deploy mysql
    Given I reset the mysql uuid
    Given I create mysql test user
    Given I create databases named db1, db2, db3, db4 on group1, group2, group3
    Given I create databases named schema1,schema2,schema3,testdb,db1,db2,db3,db4 on compare_mysql


  @use.with_dble_topo=single
  Scenario: Initialize the single DBLE
    Given a clean environment in all dble nodes
    Given install dble in "dble-1"
    Given replace config files in "dble-1" with command line config
    Then Start dble in "dble-1"



