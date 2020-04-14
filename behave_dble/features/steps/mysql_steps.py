# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM1:35
# @Author  : irene-coming
from threading import Thread

from steps.lib.MySQLObject import MySQLObject
from steps.lib.PostQueryCheck import PostQueryCheck
from steps.lib.PreQueryPrepare import PreQueryPrepare
from steps.lib.QueryMeta import QueryMeta
from steps.lib.ObjectFactory import ObjectFactory
from behave import *

global sql_threads
sql_threads = []

@Given('kill connection with query "{query}" in host "{host_name}"')
def step_impl(context, query, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.kill_conn_with_query(query)

@Given('restart mysql in "{host_name}" with sed cmds to update mysql config')
@Given('restart mysql in "{host_name}"')
def restart_mysql(context, host_name, sed_str=None):
    if not sed_str and context.text is not None and len(context.text)>0:
        sed_str = context.text

    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.restart(sed_str)

@Given('stop mysql in host "{host_name}"')
def stop_mysql(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.stop()

@Given('start mysql in host "{host_name}"')
def start_mysql(context, host_name, sed_str=None):
    if not sed_str and context.text is not None and len(context.text)>0:
        sed_str = context.text

    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.start(sed_str)

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
    mysql.check_query_in_general_log(query, expect_exist=True, expect_occur_times_expr=occur_times_expr)

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

    return res,err

@Given('prepare a thread execute sql "{sql}" with "{conn_type}"')
def step_impl(context, sql, conn_type=''):
    conn = MySQLObject.long_live_conns.get(conn_type,None)
    assert conn, "conn '{0}' is not exists in long_live_conns".format(conn_type)
    global sql_threads
    thd = Thread(target=execute_sql_backgroud, args=(context, conn, sql), name=sql)
    sql_threads.append(thd)
    thd.setDaemon(True)
    thd.start()

def execute_sql_backgroud(context, conn, sql):
    sql_cmd = sql.strip()
    res, err = conn.execute(sql_cmd)
    setattr(context,"sql_thread_result",res)
    setattr(context,"sql_thread_err",err)

@Given('destroy sql threads list')
def step_impl(context):
    global sql_threads
    for thd in sql_threads:
        context.logger.debug("join sql thread: {0}".format(thd.name))
        thd.join()


@Given('kill all backend conns in "{host_name}"')
@Given('kill all backend conns in "{host_name}" except ones in "{exclude_conn_ids}"')
def step_impl(context, host_name, exclude_conn_ids=None):
    if exclude_conn_ids:
        exclude_ids = getattr(context, exclude_conn_ids, None)

    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.kill_all_conns(exclude_ids)

@Given('kill mysql conns in "{host_name}" in "{conn_ids}"')
def step_impl(context, host_name, conn_ids):
    conn_ids = getattr(context, conn_ids, None)
    assert len(conn_ids)>0, "no conns in '{}' to kill".format(conn_ids)
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.kill_conns(conn_ids)
