import datetime
import os
import re
from lib.DBUtil import DBUtil
from behave import *
from step_check_sql import get_full_log_path, get_log_linenu
from steps.step_reload import get_admin_conn


def destroy_share_n_conn(context):
    for i in range(1,10):
        mycat_conn_name = "share_conn_{0}".format(i)
        if hasattr(context, mycat_conn_name):
            conn_mycat = getattr(context, mycat_conn_name)
            conn_mycat.close()
            delattr(context, mycat_conn_name)

def do_admin_query(context, line_nu, sql):
    sql = sql.strip()
    result = None
    if len(sql) > 0:
        context.logger.info("execute admin sql line:{0}, sql:{1}".format(line_nu, sql))
        result, err = context.conn_admin.query(sql)
        context.logger.info("admin sql err:{1}".format(result, err))

        if len(sql) > 1000:sql = "{0}...{1}".format(sql[0:300], sql[-50:])
        isNoErr = err is None

        if(isNoErr):
            with open(context.cur_pass_log, 'a') as fpT:
                fpT.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(line_nu, sql, context.sql_file))
                context.logger.info("result is: {0}".format(result))
                fpT.writelines(str(result))
        else:
            with open(context.cur_fail_log, 'a') as fpF:
                fpF.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(line_nu, sql, context.sql_file))
                fpF.writelines(str(result))
                fpF.writelines(err)

    return result

@Then('execute sql in "{filename}" to check manager work fine')
def step_impl(context, filename):
    context.sql_file = filename
    context.execute_steps(u'Given init read-write-split data')
    filepath = "sqls/{0}".format(filename)
    sql = ''
    line_nu = 0
    if (not hasattr(context, "conn_mycat")) or context.conn_mycat is None:
        context.conn_admin, err = get_admin_conn(context)
        assert err is None, "create admin conn err: {0}".format(err)


    with open(filepath) as fp:
        lines = fp.readlines()
        context.linenu = 0
        for line in lines:
            line_nu += 1
            context.logger.info("**************************************************")
            if line.startswith('#'):
                context.logger.info("jump comment line, conntions to exec sql next")
                continue
            sql = sql + line.strip() + "\n"
            do_admin_query(context, line_nu, sql)

            sql = ''




