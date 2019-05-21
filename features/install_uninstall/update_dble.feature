# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
Feature:
    Scenario: #update dble in a base environment
    Given uninstall dble in "dble-1"
    Given install dble in "dble-1"
    Then Start dble in "dble-1"
