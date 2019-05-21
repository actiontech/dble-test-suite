# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
Feature: do nothing but start dble with setups done in environment

    Scenario: do setups 
        Given Set the log level to "debug"
        Given Restart dble in "dble-1"