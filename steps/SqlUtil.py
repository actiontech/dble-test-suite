# -*- coding: utf-8 -*-
# @Time    : 2018/4/2 PM6:56
# @Author  : zhaohongjie@actionsky.com

import re
import MySQLdb
from behave import *
from hamcrest import *

from lib.DBUtil import DBUtil


def get_sql(type):
    if type == "read":
        sql="select 1 "
    else:
        sql="drop table if exists char_columns"

    return sql

@Then('execute sql')
def step_impl(context):
    exec_sql(context, context.dble_test_config['dble_host'], context.dble_test_config['client_port'])

@Then('execute admin sql')
def step_impl(context):
    exec_sql(context, context.dble_test_config['dble_host'], context.dble_test_config['manager_port'])

def exec_sql(context, ip, port):
    '''
    if row["sql"] is none, just create connection
    if row["db"] is none, query without default database
    '''
    for row in context.table:
        user = row["user"]
        passwd = row["passwd"]
        bClose = row["toClose"].lower()=="true"

        sql = row["sql"]
        if sql == "default_read":
            sql = get_sql("read")
        elif sql == "default_write":
            sql = get_sql("write")

        conn_type = row["conn"]
        expect = row["expect"]
        db = row["db"]
        if db is None: db = ''

        conn = None
        try:
            err=None
            if conn_type.lower() == "new":
                conn = DBUtil(ip, user, passwd, db, port, context)
            else:
                if hasattr(context, conn_type):
                    conn = getattr(context, conn_type)
                    context.logger.info("get conn: {0}".format(conn_type))
                else:
                    conn = DBUtil(ip, user, passwd, db, port, context)
                    setattr(context, conn_type, conn)
                    context.logger.info("create conn: {0} and setattr on context for this conn".format(conn_type))
        except MySQLdb.Error,e:
            err = e.args
        finally:
            context.logger.info("get or create conn:{0} got err:{1}".format(conn_type, err))

            if err is not None:
                context.logger.info("exec sql err is {0} {1}".format(err[0], err[1]))
            elif sql is not None and len(sql)>0:
                context.logger.info("sql:{0}, conn:{1}, err:{2}".format(sql,conn,err))
                res,err = conn.query(sql)
                if bClose:
                    conn.close()

            hasObj = re.search(r"has\{(.*?)\}", expect, re.I)
            hasnotObj = re.search(r"hasnot\{(.*?)\}", expect, re.I)

            if expect == "success":
                assert_that(err is None, "expect no err, but outcomes '{0}'".format(err))
            elif hasObj or hasnotObj:
                if hasObj:
                    expectRS=hasObj.group(1)
                    # context.logger.info("debug expectRS:{0}".format(expectRS))
                    hasResultSet(res, expectRS, True)
                if hasnotObj:
                    notExpectRS=hasnotObj.group(1)
                    # context.logger.info("debug notExpectRS:{0}".format(notExpectRS))
                    hasResultSet(res, notExpectRS, False)
            else:
                assert_that(err, not None, "Err is None, expect:{0}".format(expect))
                assert_that(err[1], contains_string(expect), "expect text: {0}".format(expect))

        context.logger.info("to close {0} {1}".format(conn_type, bClose))
        if bClose and conn is not None:
            conn.close()

            if hasattr(context, conn_type):
                delattr(context, conn_type)

def hasResultSet(res, expectRS, bHas):
    resExpect = eval(expectRS)
    if isinstance(resExpect, list):#for multi-resultset
        for subResExpect in resExpect:
            assert isinstance(res, list), "expect mult-resultset, but real not"
            real = findFromMultiRes(res, subResExpect)
            assert real == bHas, "expect {0} in resultset {1}".format(resExpect, bHas)
    else:#for single query resultset
        real = res.__contains__(resExpect)
        assert real == bHas, "expect {0} in resultset {1}".format(resExpect, bHas)

# the expext resultset must wholely in the same tuple of the mult-res list
# for example: res=[((1,2)),((3,4))], expect=((2,3)) shuold return False
def findFromMultiRes(res, expect):
    assert len(res)>0, "resultset is empty"
    if isinstance(expect, str): expLen = 1
    else: expLen = len(expect)
    for item in res:
        if item.__contains__(expect[0]):
            k = 1
            for subExpect in expect[1:]:
                if item.__contains__(subExpect): k = k+1
            if expLen == k: return True
    return False