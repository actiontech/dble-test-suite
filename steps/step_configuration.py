# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging
import re

import MySQLdb

from behave import *
from hamcrest import *
from step_reload import get_admin_conn, get_dble_conn
from lib.generate_util import *

LOGGER = logging.getLogger('steps.install')


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
