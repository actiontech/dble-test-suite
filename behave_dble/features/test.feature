# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
@setup
Feature: global table sql cover test
"""
Given rm old logs "sql_cover_global" if exists
Given reset replication and none system databases
"""

   Scenario:cover empty line in file, no line in file, chinese character in file, special character in file for sql syntax: load data [local] infile ...#1
     Given set sql cover log dir "sql_cover_global"
     Given prepare loaddata.sql data for sql test
     Then execute sql in file "sqls_util/syntax/loaddata.sql"
     Given clear dirty data yield by sql
     Given clean loaddata.sql used data
