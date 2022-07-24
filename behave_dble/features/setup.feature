# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Feature: do nothing but reset dble with command line config

    # @skip_restart
    # Scenario: do setups

# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: Deploy DBLE test environment

  @Initialize_mysql
  Scenario: Initialize the MySQL
    Given I clean mysql deploy environment
    Given I deploy mysql
    Given I reset the mysql uuid
    Given I create mysql test user
    Given I create databases named db1, db2, db3, db4 on group1, group2, Standalone

  @install_dble
  Scenario: Initialize the single DBLE
    Given I create symbolic link for mysql in dble-1
    Given a clean environment in all dble nodes
    Given install dble in "dble-1"
    Given replace config files in "dble-1" with command line config
    Then Start dble in "dble-1"


  #@use.with_dble_topo=cluster
  # Scenario: Initialize the cluster DBLE
  #   Given I clean dble deploy environment
  #   Given I install dble cluster
  #   Given I update dble cluster config file use dble conf
  #   Given I start the dble cluster


#   @skip_restart
#   Scenario: install zk cluster #1
#     Given stop dble cluster and zk service
#     Given a clean environment in all dble nodes
#     Given install dble in all dble nodes
#     Given replace config files in all dbles with command line config
#     Given config zookeeper cluster in all dble nodes with "local zookeeper host"
#     Given reset dble registered nodes in zk
#     Then start dble in order