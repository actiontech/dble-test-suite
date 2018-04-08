import datetime
import os
import re

from behave import *
from step_check_sql import get_log_linenu

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

    if type(mycat_result) == tuple and type(mysql_result) == tuple:
        if (sql.find('order by') != -1) or (sql.find('group by') != -1):
            context.logger.info("mycat:{0}".format(mycat_result))
            context.logger.info("mysql:{0}".format(mysql_result))
            result1 = tuple(mycat_result)
            result2 = tuple(mysql_result)
        else:
            result1 = sorted(tuple(mycat_result))
            result2 = sorted(tuple(mysql_result))
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
                fpT.writelines("==={0}===\n".format(mycat_re))
                fpT.writelines("==={0}===\n".format(mysql_re))
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
                        fpT.writelines("==={0}===\n".format(mycat_re))
                        fpT.writelines("==={0}===\n".format(mysql_re))
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
            fpF.writelines(mycat_re)
            fpF.writelines(mysql_re)

            if err1 is not None:
                fpF.writelines("mysql err:{0}\n".format(err1))
            if err2 is not None:
                fpF.writelines("[{1}]mycat err :{0}\n".format(err2, datetime.datetime.now().strftime('%H:%M:%S.%f')))
        context.logger.info("isResultSame false.")