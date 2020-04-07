# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午12:58
# @Author  : irene-coming
import logging
import os
import random

import time
import MySQLdb

from MySQLSteps import *
from lib.DBUtil import DBUtil
from behave import *
from hamcrest import *

from lib.ObjectFactory import ObjectFactory
from lib.PostQueryCheck import PostQueryCheck
from lib.PreQueryPrepare import PreQueryPrepare
from lib.QueryMeta import QueryMeta
from lib.generate_util import generate
from lib.MySQLMeta import MySQLMeta
from lib.DbleMeta import DbleMeta
from lib.utils import get_node

logger = logging.getLogger('steps.dble_steps')


@When('execute admin cmd "{adminsql}" success')
@Given('execute admin cmd "{adminsql}" success')
@Then('execute admin cmd "{adminsql}"')
@Then('execute admin cmd "{adminsql}" get the following output')
@Then('execute admin cmd "{adminsql}" with user "{user}" passwd "{passwd}"')
@Then('execute admin cmd "{adminsql}" with "{result}" result')
def exec_admin_cmd(context, adminsql, user="", passwd="", result=""):
    node = get_node("dble-1")
    if len(user.strip()) == 0:
        user = node.manager_user
    if len(passwd.strip()) == 0:
        passwd = str(node.manager_password)
    if len(result.strip()) != 0:
        adminsql = "{0} {1}".format(adminsql, getattr(context, result)[0][0])
    if context.text: expect = context.text
    else: expect = "success"

    context.execute_steps(u"""
    Then execute sql in "dble-1" in "admin" mode
        | user    | passwd | sql      | expect   |
        | {0}     | {1}    | {2}      | {3}      |
    """.format(user, passwd, adminsql, expect))

@When('execute sql in "{host_name}" in "{mode_name}" mode')
@Given('execute sql in "{host_name}" in "{mode_name}" mode')
@Then('execute sql in "{host_name}" in "{mode_name}" mode')
def step_impl(context, host_name, mode_name):
    for row in context.table:
        execute_dble_sql_in_host(host_name, row.as_dict(), mode_name)

def execute_dble_sql_in_host(host_name, info_dic=None, mode_name="user"):
    # logger.debug("debug4:{},{}".format(type(info_dic), info_dic))

    dble = ObjectFactory.create_dble_object(host_name)
    query_meta = QueryMeta(info_dic, mode_name, dble._dble_meta)

    pre_delegater = PreQueryPrepare(query_meta)
    pre_delegater.prepare()

    res, err, time_cost = dble.do_execute_query(query_meta)

    post_delegater = PostQueryCheck(res, err, time_cost, query_meta)
    post_delegater.check_result()

    return res,err

@Then('execute sql "{sql}" in "{host}" with "{results}" result')
def step_impl(context,sql,host,results):
    for row in context.table:
        dict = row.as_dict()
        resultList = getattr(context,results)
        for result in resultList:
            sql = sql + ' ' +'"{0}"'.format(result)
            dict.update("sql", sql)

            execute_dble_sql_in_host(host, dict, "user")

@Then('insert "{num}" rows at one time')
def step_impl(context, num):
    sql = "insert into test_table values"
    gen = generate()
    value_nu = int(num)
    for i in range(1, value_nu):
        c_str = gen.rand_string(10)
        pad_str = gen.rand_string(60)
        sql += "({0}, {0}, '{1}', '{2}'),".format(i, c_str, pad_str)

    c_str = gen.rand_string(10)
    pad_str = gen.rand_string(60)
    sql += "({0}, {0}, '{1}', '{2}')".format(i+1, c_str, pad_str)

    execute_dble_sql_in_host("dble-1", {"sql":sql}, "user")


@Then('connect "{hostname}" to insert "{num}" of data for "{tablename}"')
@Then('connect "{hostname}" to insert "{num}" of data for "{dbname}"."{tablename}"')
def step_impl(context, hostname, num, tablename, dbname="schema1"):
    sql = ("insert into {0} (id,name) values".format(tablename))
    end = int(num)
    for i in range(1, end + 1):
        inspection_num = 'NJ' + str(100000 + i)
        if (i == end):
            sql = sql + ("({0},'{1}');".format(i, inspection_num))
        else:
            sql = sql + ("({0},'{1}'),".format(i, inspection_num))

    do_batch_sql(context, hostname, dbname, sql)


@Then('connect "{hostname}" to execute "{num}" of select')
@Then('connect "{hostname}" to execute "{num}" of select for "{tablename}"')
@Then('connect "{hostname}" to execute "{num}" of select for "{dbname}"."{tablename}"')
def step_impl(context, hostname, num, tablename="", dbname="schema1"):
    end = int(num)
    for i in range(1, end + 1):
        if 0 == i % 1000:
            time.sleep(60)
        if context.text:
            sql = context.text.strip()
        else:
            id == random.randint(1, end)
            sql = ("select name from {0} where id ={1};".format(tablename, i))
        do_batch_sql(context, hostname, dbname, sql)


def do_batch_sql(context, hostname, db, sql):
    conn = None
    node = get_node(hostname)
    ip = node._ip
    user = node.client_user
    passwd = node.client_password
    port = node.client_port
    try:
        conn = DBUtil(ip, user, passwd, db, port, context)
        res, err = conn.query(sql)
    except MySQLdb.Error, e:
        errMsg = e.args
        context.logger.info("try to create conn and exec sql:{0} failed:{1}".format(sql, errMsg))
    finally:
        try:
            conn.close()
        except:
            context.logger.info("close conn failed!")
    assert_that(err is None, "excute batch sql: '{0}' failed! outcomes:'{1}'".format(sql, err))

@Then('initialize mysql-off-step sequence table')
def step_impl(context):
    mysql_node = get_node("mysql-master1")

    # copy dble's dbseq.sql to local
    dble_node = get_node("dble-1")
    source_remote_file = "{0}/dble/conf/dbseq.sql".format(dble_node.install_dir)
    target_remote_file = "{0}/data/dbseq.sql".format(mysql_node.install_path)
    local_file  = "{0}/dbseq.sql".format(os.getcwd())

    ssh_client = mysql_node.ssh_conn;

    cmd="rm -rf {0}".format(local_file)
    ssh_client.exec_command(cmd);

    context.ssh_sftp.sftp_get(source_remote_file, local_file)
    mysql_node.sftp_conn.sftp_put(local_file, target_remote_file)

    cmd = "mysql -utest -p111111 db1 < {0}".format(target_remote_file)
    ssh_client.exec_command(cmd)

    #execute dbseq.sql at the node configed in sequence file
    execute_sql_in_host("mysql-master1", info_dic={"sql":"insert into DBLE_SEQUENCE values ('`schema1`.`test_auto`', 3, 1)", "db":"db1"})

@Given('execute single sql in "{host_name}" and save resultset in "{result_key}"')
@Given('execute single sql in "{host_name}" in "{mode_name}" mode and save resultset in "{result_key}"')
def step_impl(context, host_name, result_key, mode_name=None):
    row = context.table[0]
    info_dict = row.as_dict()
    if mode_name in ["admin", "user"]:#query to dble
        res, _ = execute_dble_sql_in_host(host_name, info_dict, mode_name)
    else:
        res, _ = execute_sql_in_host(host_name, info_dict)

    setattr(context, result_key, res)

