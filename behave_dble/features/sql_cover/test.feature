# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
Feature: basic sql translate/transmission correct, seperate read/write statements, read load balance

    Scenario: #5 compare new generated results is same with the standard ones
        When compare results with the standard results in "std_result"