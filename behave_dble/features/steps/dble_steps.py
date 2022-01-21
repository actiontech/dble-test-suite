# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午12:58
# @Author  : irene-coming
import logging
import os
import random

import time
import MySQLdb

from steps.mysql_steps import *
from steps.lib.DBUtil import DBUtil
from behave import *
from hamcrest import *

from steps.lib.ObjectFactory import ObjectFactory
from steps.lib.PostQueryCheck import PostQueryCheck
from steps.lib.PreQueryPrepare import PreQueryPrepare
from steps.lib.QueryMeta import QueryMeta
from steps.lib.generate_util import generate
from steps.lib.utils import get_node

from steps.mysql_steps import execute_sql_in_host

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
        execute_sql_in_host(host_name, row.as_dict(), mode_name)

@Then('execute sql "{sql}" in "{host}" with "{results}" result')
def step_impl(context,sql,host,results):
    for row in context.table:
        dict = row.as_dict()
        resultList = getattr(context,results)
        for result in resultList:
            sql = sql + ' ' +'"{0}"'.format(result)
            dict.update({"sql": sql})

            execute_sql_in_host(host, dict, "mysql")

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

    execute_sql_in_host("dble-1", {"sql":sql}, "user")


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

    execute_sql_in_host(hostname, {"sql":sql,"db":dbname}, "user")

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
    key = result_key
    res, _ = execute_sql_in_host(host_name, info_dict, mode_name)

    setattr(context, result_key, res)
    # print("the {0} is {1}\n\n\n\n".format(key, getattr(context, result_key)))

@Then('execute admin cmd  in "{host}" at background')
@Then('execute "{mode_name}" cmd  in "{host}" at background')
def step_impl(context, host, mode_name="admin"):
    node = get_node(host)

    context.logger.debug("btrace is running, start query!!!")
    time.sleep(5)
    for row in context.table:
        if mode_name=="admin":
            query_meta = QueryMeta(row.as_dict(), "admin", node)
        else:
            query_meta = QueryMeta(row.as_dict(), "user", node)

        cmd = u"nohup mysql -u{} -p{} -P{} -c -D{} -e\"{}\" >/tmp/dble_{}_query.log 2>&1 &".format(query_meta.user, query_meta.passwd, query_meta.port, query_meta.db, query_meta.sql,mode_name)
        rc, sto, ste = node.ssh_conn.exec_command(cmd)
        assert len(ste) == 0, "impossible err occur"


