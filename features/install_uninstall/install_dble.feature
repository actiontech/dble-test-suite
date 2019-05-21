# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
Feature: install single dble

  @smoke
  Scenario: install single dble in a clean environment
    Given a clean environment in all dble nodes
    Given install dble in "dble-1"
    Then Start dble in "dble-1"