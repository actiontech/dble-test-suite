# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM1:35
# @Author  : irene-coming
import logging
from threading import Thread

from steps.lib.Flag import Flag
from steps.lib.MySQLObject import MySQLObject
from steps.lib.PostQueryCheck import PostQueryCheck
from steps.lib.PreQueryPrepare import PreQueryPrepare
from steps.lib.QueryMeta import QueryMeta
from steps.lib.ObjectFactory import ObjectFactory
from behave import *

global sql_threads
sql_threads = []

logger = logging.getLogger('steps.mysql_steps')

@Given('restart mysql in "{host_name}" with sed cmds to update mysql config')
@Given('restart mysql in "{host_name}"')
def restart_mysql(context, host_name, sed_str=None):
    if not sed_str and context.text is not None and len(context.text)>0:
        sed_str = context.text

    mysql = ObjectFactory.create_mysql_object(host_name)
    # this is temp for debug stop mysql fail
    execute_sql_in_host(host_name,{'sql':'show processlist'})
    # end debug stop mysql fail
    mysql.restart(sed_str)

@Given('stop mysql in host "{host_name}"')
def stop_mysql(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)

    # this is temp for debug stop mysql fail
    execute_sql_in_host(host_name,{'sql':'show processlist'})
    # end debug stop mysql fail

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

def execute_sql_in_host(host_name, info_dic, mode="mysql"):
    if mode in ["admin", "user"]:#query to dble
        obj = ObjectFactory.create_dble_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._dble_meta)
    else:
        obj = ObjectFactory.create_mysql_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._mysql_meta)

    pre_delegater = PreQueryPrepare(query_meta)
    pre_delegater.prepare()

    res, err, time_cost = obj.do_execute_query(query_meta)

    post_delegater = PostQueryCheck(res, err, time_cost, query_meta)
    post_delegater.check_result()

    return res, err

@Given('execute sql "{num}" times in "{host_name}" at concurrent')
@Given('execute sql "{num}" times in "{host_name}" at concurrent {concur}')
def step_impl(context, host_name, num, concur="100"):
    row = context.table[0]
    num = int(num)
    info_dic = row.as_dict()
    concur = min(int(concur), num)

    tasks_per_thread = num/concur
    mod_tasks = num%concur

    def do_thread_tasks(host_name, info_dic, base_id, tasks_count, eflag):
        my_dic = info_dic.copy()
        my_dic["conn"] = "concurr_conn_{}".format(i)
        my_dic["toClose"] = "False"
        last_count = tasks_count-1
        sql_raw = my_dic["sql"]
        for k in range(tasks_count):
            if k==last_count:
                my_dic["toClose"] = "true"
            id = base_id+k
            my_dic["sql"] = sql_raw.format(id)
            # logger.debug("debug1, my_dic:{}, conn:{}".format(my_dic["sql"], my_dic["conn"]))
            try:
                execute_sql_in_host(host_name, my_dic, "user")
            except Exception as e:
                eflag.exception = e

    for i in range(concur):
        if i < mod_tasks:
            tasks_count = tasks_per_thread + 1
        else:
            tasks_count = tasks_per_thread
        base_id = i*tasks_per_thread
        thd = Thread(target=do_thread_tasks, args=(host_name, info_dic, base_id, tasks_count, Flag))
        thd.start()
        thd.join()

        if Flag.exception:
            raise Flag.exception

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
    else:
        exclude_ids = []

    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.kill_all_conns(exclude_ids)

@Given('kill mysql conns in "{host_name}" in "{conn_ids}"')
def step_impl(context, host_name, conn_ids):
    conn_ids = getattr(context, conn_ids, None)
    assert len(conn_ids)>0, "no conns in '{}' to kill".format(conn_ids)
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.kill_conns(conn_ids)

