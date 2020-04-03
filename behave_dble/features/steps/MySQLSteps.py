# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM1:35
# @Author  : irene-coming
from .lib import MySQLFacotry
from behave import *


@Given('kill connection with query "{query}" in host "{hostname}"')
def step_impl(context, query, hostname):
    mysql = MySQLFacotry.createMySQLObject(context, hostname)
    mysql.killConnByQuery(query)
