import logging
import time

import MySQLdb

from behave import *
from hamcrest import *

from steps.step_thread import MyThread
from step_reload import get_admin_conn, get_dble_conn
from lib.generate_util import *

LOGGER = logging.getLogger('steps.install')

my_thread={}

@Then('get limited results')
def get_limit_result(context):
    num = int(context.text)
    conn = get_dble_conn(context)

    select_sql = "select * from test_table"
    res, errMsg = conn.query(select_sql)
    conn.close()

    LOGGER.info("the length of limit result is:{0}".format(len(res)))

    assert_that(len(res), equal_to(num))


@Then('create "{num}" conn')
def create_conn(context,num):
    num = int(num)
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

            assert_that(context.text,contains_string("can't create connections more than maxCon"))
    for conn in conns:
        conn.close()

@Given('create "{num}" front connections executing "{sql}"')
def step_impl(context, num, sql):
    nu = int(num)
    for i in range(nu):
        connName = "conn_"+str(i)
        context.logger.info("***debug, conn name: {0}, i:{1}".format(connName, i))
        conn = get_dble_conn(context)

        long_sql_thread = MyThread(context, conn, sql, True)
        thd_name = "sql_thread_"+connName
        context.logger.info("create thread: {0}".format(thd_name))
        long_sql_thread.start()
