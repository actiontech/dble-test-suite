import logging
import time

import MySQLdb

from behave import *
from hamcrest import *

from step_thread import DbleThread
from step_reload import get_admin_conn, get_dble_conn
from lib.generate_util import *

LOGGER = logging.getLogger('steps.install')

my_thread={}

@Then('create "{num}" conn while maxCon="{maxNum}" finally close all conn')
def create_conn(context,num,maxNum):
    num = int(num)
    maxNum = int(maxNum)
    conns = []
    try:
        err = None
        for i in range(0,num):
            context.logger.info("create {0} conn begin:##########################".format(i+1))
            conn = get_dble_conn(context)
            cur = conn._cursor
            cur.execute('start transaction')
            cur.execute('select 1')
            conns.append(conn)

        context.logger.info("create conn: {0} conns have been created".format(len(conns)))
    except MySQLdb.Error, e:
        err = e.args
    finally:
        if err is not None:
            context.logger.info("create conn: got err:{0}".format(err))
            context.logger.info("create maxCon is {0}".format(i))
            assert_that(err[1],contains_string(context.text.strip()))
        else:
            context.logger.info("*************create maxCon is {0}******************".format(i+1))
            assert i+1<=maxNum,"can not create conns more than {0}".format(maxNum)
    for conn in conns:
        conn.close()

@Given('create "{num}" front connections executing "{sql}"')
def step_impl(context, num, sql):
    nu = int(num)
    for i in range(nu):
        connName = "conn_"+str(i)
        context.logger.info("***debug, conn name: {0}, i:{1}".format(connName, i))
        conn = get_dble_conn(context)

        long_sql_thread = DbleThread(context, conn, sql, True)
        thd_name = "sql_thread_"+connName
        context.logger.info("create thread: {0}".format(thd_name))
        long_sql_thread.start()
