# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM1:35
# @Author  : irene-coming
from .lib.PostQueryCheck import PostQueryCheck
from .lib.PreQueryPrepare import PreQueryPrepare
from .lib.QueryMeta import QueryMeta
from .lib.ObjectFactory import ObjectFactory
from behave import *


@Given('kill connection with query "{query}" in host "{host_name}"')
def step_impl(context, query, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.killConnByQuery(query)

@Given('restart mysql in "{host_name}" with sed cmds to update mysql config')
@Given('restart mysql in "{host_name}"')
def restart_mysql(context, host_name, sed_str=None):
    if not sed_str and len(context.text)>0:
        sed_str = context.text()

    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.restart(sed_str)

@Given('stop mysql in host "{host_name}"')
def stop_mysql(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.stop()

@Given('start mysql in host "{host_name}"')
def start_mysql(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.start()

@Given('turn on general log in "{host_name}"')
def step_impl(context,host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.turn_on_general_log()

@Given('turn off general log in "{host_name}"')
def turn_off_general_log(context,host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.turn_off_general_log()

@Then('check general log in host "{host_name}" has not "{query}"')
def step_impl(context,host_name, query):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.check_query_in_general_log(query, expect_exist=False)

@Then('check general log in host "{host_name}" has "{query}"')
@Then('check general log in host "{host_name}" has "{query}" occured "{occur_times_expr}" times')
def step_impl(context,host_name, query, occur_times_expr=None):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.check_query_in_general_log(query, expect_exist=True, occur_times_expr=occur_times_expr)

@Given('execute sql in "{host_name}"')
@Then('execute sql in "{host_name}"')
def step_impl(context, host_name):
    for row in context.table:
        execute_sql_in_host(host_name, row.as_dict())

def execute_sql_in_host(host_name, info_dic=None):
    mysql = ObjectFactory.create_mysql_object(host_name)
    query_meta = QueryMeta(info_dic, "mysql", mysql._mysql_meta)

    pre_delegater = PreQueryPrepare(query_meta)
    pre_delegater.prepare()

    res, err, time_cost = mysql.do_execute_query(query_meta)

    post_delegater = PostQueryCheck(res, err, time_cost, query_meta)
    post_delegater.check_result()


