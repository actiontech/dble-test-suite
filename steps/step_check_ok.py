import datetime
import os
import re
from lib.DBUtil import DBUtil
from behave import *
from step_check_sql import get_full_log_path, get_log_linenu

def get_compare_conn(context, default_db="mytest"):
    conn_dble = DBUtil(context.dble_test_config['dble_host'], context.dble_test_config['client_user'],
                       context.dble_test_config['client_password'],
                       default_db, context.dble_test_config['client_port'], context)
    return conn_dble

def destroy_share_n_conn(context):
    for i in range(1,10):
        mycat_conn_name = "share_conn_{0}".format(i)
        if hasattr(context, mycat_conn_name):
            conn_mycat = getattr(context, mycat_conn_name)
            conn_mycat.close()
            delattr(context, mycat_conn_name)

def do_query(context, line_nu, sql, toClose, default_db="mytest"):
    sql = sql.strip()
    result2 = None
    if len(sql) > 0:
        context.logger.info("==={0} {1} {2}===".format(context.sql_file,line_nu, sql))
        get_log_linenu(context)

        if (not hasattr(context, "conn_mycat")) or context.conn_mycat is None:
            context.logger.info("default db is : {0}".format(default_db))
            context.conn_mycat = get_compare_conn(context, default_db)
        result2, err2 = context.conn_mycat.query(sql)
        context.logger.info("check sql result:")
        compare_result(context, line_nu, sql, result2, err2)
        context.logger.info("toClose value is : {0}".format(toClose))
        if toClose:
            context.conn_mycat.close()
            context.conn_mycat = None
    return result2

def compare_result(context, id, sql, mycat_result, err2):
    if len(sql) > 1000:sql = "{0}...{1}".format(sql[0:300], sql[-50:])
    isNoErr = err2 is None
    mycat_re = "mycat:[" + str(mycat_result) +"]\n"

    if not hasattr(context, 'sql_file'):
        context.sql_file = "lock.sql"
    if(isNoErr):
        context.logger.info("isNoErr is true, but result may be false")
        with open(context.cur_pass_log, 'a') as fpT:
            fpT.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
            context.logger.info("mysql_err == null && mycat_err == null")
    else:
        with open(context.cur_fail_log, 'a') as fpF:
            fpF.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
            fpF.writelines(mycat_re)

            if err2 is not None:
                fpF.writelines("[{1}]mycat err :{0}\n".format(err2, datetime.datetime.now().strftime('%H:%M:%S.%f')))

@Then('execute sql in "{filename}" to check manager work fine')
def step_impl(context, filename):
    context.sql_file = filename
    context.execute_steps(u'Given init read-write-split data')
    filepath = "sqls/{0}".format(filename)
    sql = ''
    line_nu = 0
    with open(filepath) as fp:
        lines = fp.readlines()
        default_db = "mytest"
        context.linenu = 0
        for line in lines:
            line_nu += 1
            context.logger.info("**************************************************")
            if line.startswith('#'):
                context.logger.info("conntions to exec sql: new")
                continue
            sql = sql + line.strip() + "\n"
            toClose = False
            do_query(context, line_nu, sql, toClose, default_db)
            sql = ''
            destroy_share_n_conn(context)





