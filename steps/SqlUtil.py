# -*- coding: utf-8 -*-
# @Time    : 2018/4/2 PM6:56
# @Author  : zhaohongjie@actionsky.com

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
                re,err = conn.query(sql)
                if bClose:
                    conn.close()

            if expect == "success":
                assert_that(err is None, "expect no err, but outcomes '{0}'".format(err))
            elif expect.startswith("resultSet_"):
                setattr(context, expect, re)
            else:
                assert_that(err, not None, "Err is None, expect:{0}".format(expect))
                assert_that(err[1], contains_string(expect), "expect text: {0}".format(expect))

        context.logger.info("to close {0} {1}".format(conn_type, bClose))
        if bClose and conn is not None:
            conn.close()

            if hasattr(context, conn_type):
                delattr(context, conn_type)
