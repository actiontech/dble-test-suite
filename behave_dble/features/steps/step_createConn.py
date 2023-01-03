# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging
import time
import re
from threading import Thread

import MySQLdb
from behave import *
from hamcrest import *

from steps.step_reload import get_dble_conn

LOGGER = logging.getLogger('root')

my_thread = {}


def createConn(context, num, sql):
    num = int(num)
    conn = None
    global errs
    errs = []
    if sql:
        exec_sql = sql
    else:
        exec_sql = "insert into test_table values(1)"
    try:
        context.logger.info("create {0} conn begin:##########################".format(num))
        conn = get_dble_conn(context)
        conn.autocommit(0)
        res, err = conn.query(exec_sql)
        if err:
            context.logger.info("create {0} conn fail!:##########################".format(num))
            errs.append(err)
        time.sleep(5)
        conn.commit()
    except MySQLdb.Error as e:
        context.logger.info("get error{0}:##########################".format(e.args))
    finally:
        if conn is not None:
            conn.close()


@Then('create "{num}" conn while maxCon="{maxNum}" finally close all conn')
def step_impl(context, num, maxNum):
    num = int(num)
    maxNum = int(maxNum)
    thread_list = []
    for i in range(0, num):
        td = Thread(target=createConn, args=(context, i, ''))
        thread_list.append(td)
        td.start()

    for thread in thread_list:
        thread.join()

    if context.text:
        assert len(errs) > 0, "expect get err,but no err"

        hasExpect = re.search(context.text, errs[0][1], re.I)
        assert hasExpect, "expect err:{0}, but real err is: {1}".format(context.text, errs[0][1])
    else:
        if errs:
            assert False, "expect no err,but outcomes:{0} when create conn".format(errs[0])
        assert num-len(errs) <= maxNum, "can not create conns more than {0}".format(maxNum)


@Given('create "{num}" front connections executing "{sql}"')
def step_impl(context, num, sql):
    num = int(num)
    thread_list = []
    for i in range(0, num):
        td = Thread(target=createConn, args=(context, i, sql))
        thread_list.append(td)
        td.start()

    for thread in thread_list:
        thread.join()

    if context.text:
        context.logger.info("create conn got err:{0}".format(errs))
        assert_that(errs[0][1], contains_string(context.text.strip()), "expect get err,but err is:{0}".format(errs))
    else:
        if errs:
            assert False, "expect no err,but outcomes:{0} when create conn".format(errs)
