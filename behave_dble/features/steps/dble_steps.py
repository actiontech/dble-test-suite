# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午12:58
# @Author  : irene-coming
import logging
from behave import *
from hamcrest import *

from lib.ObjectFactory import ObjectFactory
from lib.PostQueryCheck import PostQueryCheck
from lib.PreQueryPrepare import PreQueryPrepare
from lib.QueryMeta import QueryMeta
from lib.generate_util import generate
from lib.MySQLMeta import MySQLMeta
from lib.DbleMeta import DbleMeta
logger = logging.getLogger('steps.dble_steps')


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
