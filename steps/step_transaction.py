import datetime
import os
import re
from behave import *
from step_check_sql import get_log_linenu, get_compare_conn, destroy_share_n_conn

def do_query(context, line_nu, sql, toClose, session1, session2, default_db="mytest"):
    sql = sql.strip()
    if len(sql)>0:
        context.logger.info("==={0} {1} {2}===".format(context.sql_file,line_nu, sql))
        get_log_linenu(context)
        if (not hasattr(context, "conn_dble")) or context.conn_dble is None:
            context.logger.info("default db is : {0}".format(default_db))
            context.conn_mysql1, context.conn_dble1 = get_compare_conn(context, default_db)
            context.conn_mysql2, context.conn_dble2 = get_compare_conn(context, default_db)
            context.conn_mysql = context.conn_mysql1
            context.conn_dble = context.conn_dble1
        if session1:
            context.logger.info(" use session 1 sucessed ")
            context.conn_mysql = context.conn_mysql1
            context.conn_dble = context.conn_dble1
            session1 = False
        if session2:
            context.logger.info(" use session 2 sucessed ")
            context.conn_mysql = context.conn_mysql2
            context.conn_dble = context.conn_dble2
            session2 = False
        result1, err1 = context.conn_mysql.tran_query(sql, toClose)
        result2, err2 = context.conn_dble.tran_query(sql, toClose)
        context.logger.info("compare sql result:")
        compare_result(context, line_nu, sql, result1, result2, err1, err2)
        context.logger.info("toClose value is : {0}".format(toClose))
        context.logger.info("mysql use session is : {0}".format(context.conn_mysql))
        context.logger.info("dble use session is : {0}".format(context.conn_dble))
        if toClose:
            context.conn_mysql = None
            context.conn_dble = None
    return session1, session2

def compare_result(context, id, sql, mysql_result, mycat_result, err1, err2):
    if len(sql)>1000: sql = "{0}...{1}".format(sql[0:300], sql[-50:])
    a = re.compile(r'\/\*\s*hang\s*\*\/')
    b = re.search(a, sql)
    c = re.compile(r'\/\*\s*allow_diff\s*\*\/')
    d = re.search(c, sql)
    isHang = b is not None
    isAllowDiff = d is not None
    isNoErr = err1 is None and err2 is None

    isResultSame = isNoErr or isAllowDiff
    context.logger.info("isNoErr:{0},isAllowDiff:{1},isResultSame:{2}".format(isNoErr, isAllowDiff, isResultSame))
    result1 = sorted(mycat_result)
    result2 = sorted(mysql_result)
    isResultSame = len(result1) == len(result2) or mycat_result == mysql_result or (isNoErr and isAllowDiff)

    mycat_re = "mycat:[" + str(mycat_result) +"]\n"
    mysql_re = "mysql:[" + str(mysql_result) +"]\n"

    if not hasattr(context, 'sql_file'):
        context.sql_file = "lock.sql"

    if(isResultSame):
        context.logger.info("isResultSame is true, but err may be different")
        if isNoErr:
            with open(context.cur_pass_log, 'a') as fpT:
                fpT.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
                if isAllowDiff:
                    fpT.writelines(mycat_re)
                    fpT.writelines(mysql_re)
            context.logger.info("mysql_err == null && mycat_err == null")
        else:
            if err1 is None:
                isMysqlSynErr = None
            else:
                isMysqlSynErr = err1[1].find('You have an error in your SQL syntax') != -1
            if err2 is None:
                isMycatSynErr = None
            else:
                isMycatSynErr = err2[1].find('not supported') != -1
            if err1 == err2 or (isMysqlSynErr and isMycatSynErr):
                isFindHang = err1.find('function run too long') != -1
                context.logger.info("isHang:{0},isFindHang:{1}".format(isHang,isFindHang))
                if isHang and isFindHang:
                    with open(context.cur_pass_log, 'a') as fpT:
                        fpT.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
                else:
                    log_file = context.cur_warn_log
                    with open(log_file, 'a') as fpW:
                        fpW.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
                        fpW.writelines("mysql err:{0}\n".format(err1))
                        fpW.writelines(
                            "mycat err[{1}] :{0}\n".format(err2, datetime.datetime.now().strftime('%H:%M:%S.%f')))
            else:
                log_file = context.cur_serious_warn_log
                with open(log_file, 'a') as fpW:
                    fpW.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
                    fpW.writelines("mysql err:{0}\n".format(err1))
                    fpW.writelines(
                        "mycat err[{1}] :{0}\n".format(err2, datetime.datetime.now().strftime('%H:%M:%S.%f')))

            context.logger.info("mysql_err: {0}".format(err1))
            context.logger.info("mycat_err: {0}".format(err2))
    else:
        with open(context.cur_fail_log, 'a') as fpF:
            fpF.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id,sql, context.sql_file))
            # reMysql = "mysql:[" + str(mysql_result) +"]\n"
            fpF.writelines(mycat_re)
            fpF.writelines(mysql_re)

            if err1 is not None:
                fpF.writelines("mysql err:{0}\n".format(err1))
            if err2 is not None:
                fpF.writelines("[{1}]mycat err :{0}\n".format(err2, datetime.datetime.now().strftime('%H:%M:%S.%f')))
        context.logger.info("isResultSame false.")

@Then('Then execute sql in "{filename}" to check tansaction work fine')
def step_impl(context, filename):
    context.sql_file=filename
    context.execute_steps(u'Given init read-write-split data')
    filepath = "sqls/{0}".format(filename)
    sql = ''
    line_nu = 0
    with open(filepath) as fp:
        lines = fp.readlines()
        toClose = True
        session1 = False
        session2 = False
        default_db = "mytest"
        context.linenu = 0
        for line in lines:
            line_nu+=1
            context.logger.info("**************************************************")
            if line.startswith('#!share_conn'):
                toClose = False
                continue
            if line.startswith('#!session 1'):
                context.logger.info("use session 1 to excute new sql")
                session1 = True
                continue
            if line.startswith('#!session 2'):
                context.logger.info("use session 2 to excute new sql")
                session2 = True
                continue
            if line.startswith('#'):
                context.logger.info("conntions to exec sql: new")
                continue
            sql = sql + line.strip() + "\n"
            session1, session2 = do_query(context, line_nu, sql, toClose, session1, session2, default_db)
            sql = ''
            destroy_share_n_conn(context)
