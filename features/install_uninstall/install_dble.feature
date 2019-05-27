# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: #install dble
  Scenario: #install single dble in a clean environment
    Given a clean environment in all dble nodes
    Given install dble in "dble-1"
    Then Start dble in "dble-1"