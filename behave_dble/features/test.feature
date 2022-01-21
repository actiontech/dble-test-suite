# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: global table sql cover test

   Scenario:a test
     Given execute sql in "dble-1" in "user" mode
     Given Restart dble in "dble-1" success

