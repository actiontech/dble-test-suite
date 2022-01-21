# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import os
import threading
from behave_dble.features.steps.lib.utils import get_node

coding= 'utf8'
import logging
from behave import *
from hamcrest import *

from step_reload import get_dble_conn

LOGGER = logging.getLogger('steps.sequence')

def insertOneRow(context, table, rowsPerThread):
    conn = get_dble_conn(context)
    sql = "insert into {0} values('abc')".format(table)
    context.logger.debug("execute query in subthread")
    for i in range(rowsPerThread):
        res, errMsg = conn.query(sql)
        assert errMsg is None, "expect '{0}' success, but get: {1}".format(sql, errMsg)
    conn.close()

@Then('insert "{totalsRowsInsert:d}" rows to global sequence table "{table}" in "{threadNum:d}" thread')
def step_impl(context, totalsRowsInsert, table, threadNum):
    realThreadNum = min(totalsRowsInsert, threadNum)
    rowsPerThread = totalsRowsInsert/threadNum
    roundantRows = totalsRowsInsert%threadNum

    threadsList = []
    for k in range(realThreadNum):
        if k < roundantRows:
            rowsPerThread = rowsPerThread + 1
        LOGGER.debug("rowsPerThread to insert : {0}".format(rowsPerThread))
        thd_name = "insert_thd_{0}".format(k)
        thd = threading.Thread(target=insertOneRow, name=thd_name, args=(context, table, rowsPerThread))
        threadsList.append(thd)

    for i in range(realThreadNum):
        threadsList[i].start()

    for i in range(realThreadNum):
        threadsList[i].join()