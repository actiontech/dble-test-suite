# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging
import thread
import time

import MySQLdb
from behave import *
from hamcrest import *

from step_reload import get_dble_conn

LOGGER = logging.getLogger('steps.install')

my_thread={}
def createConn(context,num,sql):
    num = int(num)
    global errs
    errs = []
    if sql:
        exec_sql=sql
    else:
        exec_sql="insert into test_table values(1)"
    try:
        context.logger.info("create {0} conn begin:##########################".format(num))
        conn = get_dble_conn(context)
        conn.autocommit(0)
        res,err=conn.query(exec_sql)
        if err:
            context.logger.info("create {0} conn fail!:##########################".format(num))
            errs.append(err)
        time.sleep(5)
        conn.commit()
        conn.close()
    except MySQLdb.Error, e:
        conn.close()
        if e.args:
            context.logger.info("get error{0}:##########################".format(e.args))
        


@Then('create "{num}" conn while maxCon="{maxNum}" finally close all conn')
def step_impl(context,num,maxNum):
    num = int(num)
    maxNum = int(maxNum)

    for i in range(0,num):
        context.logger.info("````````````````````````````{0}".format(i))
        thread.start_new_thread(createConn,(context,i,''))

    time.sleep(15)
    if context.text:
        context.logger.info("create conn got err:{0}".format(errs[0]))
        assert errs, "expect get err,but err is:{0}".format(errs[0])
    else:
        if errs:
            assert False, "expect no err,but outcomes:{0} when create conn".format(errs[0])
        assert num-len(errs) <= maxNum, "can not create conns more than {0}".format(maxNum)


@Given('create "{num}" front connections executing "{sql}"')
def step_impl(context, num, sql):
    num = int(num)
    for i in range(0,num):
        thread.start_new_thread(createConn,(context,i,sql))
    time.sleep(10)
    if context.text:
        context.logger.info("create conn got err:{0}".format(errs))
        assert_that(errs[0][1],contains_string(context.text.strip()),"expect get err,but err is:{0}".format(errs))
    else:
        if errs:
            assert False, "expect no err,but outcomes:{0} when create conn".format(errs)
