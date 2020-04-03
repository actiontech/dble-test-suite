# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM1:35
# @Author  : irene-coming
from .lib import MySQLFacotry
from behave import *


@Given('kill connection with query "{query}" in host "{host_name}"')
def step_impl(context, query, host_name):
    mysql = MySQLFacotry.createMySQLObject(context, host_name)
    mysql.killConnByQuery(query)

@Given('restart mysql in "{host_name}" with sed cmds to update mysql config')
@Given('restart mysql in "{host_name}"')
def restart_mysql(context, host_name, sed_str=None):
    if not sed_str and len(context.text)>0:
        sed_str = context.text()

    mysql = MySQLFacotry.createMySQLObject(context, host_name)
    mysql.restart(sed_str)

@Given('stop mysql in host "{host_name}"')
def stop_mysql(context, host_name):
    mysql = MySQLFacotry.createMySQLObject(context, host_name)
    mysql.stop()

@Given('start mysql in host "{host_name}"')
def start_mysql(context, host_name):
    mysql = MySQLFacotry.createMySQLObject(context, host_name)
    mysql.start()