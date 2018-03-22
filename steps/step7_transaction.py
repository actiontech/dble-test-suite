import datetime
import os
import re

from behave import *
from ssh import SSH
from util import get_log_linenu

from lib.DBUtil import DBUtil


@Given('init transaction_test data')
def step_impl(context):
    subdir = context.result + "/"
    if context.sql_file.find("/") == -1:
        sql_file_name = context.sql_file
    else:
        group = context.sql_file.partition("/");
        sql_file_name = group[2]
        subdir = subdir + group[0]
        if not os.path.exists(subdir):
            os.mkdir(subdir)

        subdir = subdir + "/"

    sql_file_name = sql_file_name.split(".")[0]
    context.cur_pass_log = "{0}{1}_pass.log".format(subdir,sql_file_name)
    context.cur_fail_log = "{0}{1}_fail.log".format(subdir,sql_file_name)
    context.cur_warn_log = "{0}{1}_warn.log".format(subdir,sql_file_name)

    if re.search(r'^route',sql_file_name):
        context.cur_route_log = "{0}{1}_send.log".format(subdir,sql_file_name)
    context.cur_serious_warn_log = "{0}/{1}_serious_warn.log".format(subdir,sql_file_name)

def get_compare_conn(context, default_db="mytest"):
    m_ip = context.mycat.ip
    m_user = context.mycat.user
    m_passwd = context.mycat.passwd
    m_port = context.mycat.port

    conn_mycat = DBUtil(m_ip, m_user, m_passwd, default_db, m_port, context)
    #conn_mycat = None
    conn_mysql = DBUtil(context.mysql.ip, context.mysql.user, context.mysql.passwd,default_db, context.mysql.port, context)

    return conn_mysql, conn_mycat

def destroy_share_n_conn(context):
    for i in range(1,10):
        mycat_conn_name = "share_conn_{0}".format(i)
        mysql_conn_name = "{0}_mysql".format(mycat_conn_name)
        if hasattr(context, mycat_conn_name):
            conn_mycat = getattr(context, mycat_conn_name)
            conn_mysql = getattr(context, mysql_conn_name)
            conn_mycat.close()
            conn_mysql.close()
            delattr(context, mycat_conn_name)
            delattr(context, mysql_conn_name)

def do_query(context, line_nu, sql, to_close, default_db="mytest"):
    result2 = None
    if len(sql)>0:
        sql = re.sub("(/*\s*uproxy_dest\s*:\s*)+slave(\d)", lambda x: x.group(1) + context.group1.slaves[int(x.group(2))-1], sql)
        get_log_linenu(context)

        reset_autocommit = False
        if sql.endswith("#!autocommit=False"):
            reset_autocommit = True
            sql = sql.replace("#!autocommit=False", "").strip()
            context.conn_mysql.autocommit(False)
            context.conn_uproxy.autocommit(False)

        result1, err1 = context.conn_mysql.query(sql)
        result2, err2 = context.conn_uproxy.query(sql)

        if reset_autocommit:
            context.conn_mysql.autocommit(True)
            context.conn_uproxy.autocommit(True)

        context.logger.info("compare sql result:")
        compare_result(context, line_nu, sql, result1, result2, err1, err2)
        context.logger.info("toClose is : {0}".format(to_close))
        if to_close:
            context.conn_mysql.close()
            context.conn_uproxy.close()
            context.conn_mysql = None
            context.conn_uproxy = None
    return result2

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


@Then('execute sql in "{filename}" to check tansaction work fine')
def step_impl(context, filename):
    context.sql_file=filename
    context.execute_steps(u'Given init transaction_test data')

    filepath = "sqls/{0}".format(filename)
    sql = ''
    is_multiline = False
    is_share_conn = False
    with open(filepath) as fp:
        lines = fp.readlines()
        total_lines = len(lines)
        line_nu=0
        default_db = "mytest"
        step_len = 1;
        next_line = lines[0].strip()
        for idx in range(0,total_lines):
            if line_nu>idx: continue
            line = next_line
            line_nu+=step_len
            is_next_line_exist = line_nu<total_lines
            if is_next_line_exist:
                step_len = 1
                next_line = lines[line_nu].strip()
                while is_next_line_exist and len(next_line)==0:
                    next_line_nu = line_nu+step_len
                    is_next_line_exist = next_line_nu<total_lines
                    if is_next_line_exist:
                        next_line = lines[next_line_nu].strip()
                        step_len += 1

            is_next_line_milestone = (not is_next_line_exist) or next_line.startswith("#")

            context.logger.info("********* {2} line {1}: {0} **********".format(line,line_nu,filename))
            if line.startswith('#'):
                is_share_conn = False
                if line.find('#!share_conn') != -1:
                    r = re.search('share_conn_?\d*', line)
                    uproxy_conn_name = r.group()
                    mysql_conn_name = "{0}_mysql".format(uproxy_conn_name)
                    if not hasattr(context, uproxy_conn_name):
                        conn_mysql, conn_uproxy = get_compare_conn(context, default_db)
                        setattr(context, uproxy_conn_name, conn_uproxy)
                        setattr(context, mysql_conn_name, conn_mysql)
                    is_share_conn = True

                elif line.startswith('#!restart-mysql'):
                    options = line.partition("::")[2].strip()
                    context.execute_steps(u'Given restart mysql with options "{0}" and reconnect success'.format(options))
                elif line.startswith('#!restart-uproxy'):
                    options = line.partition("::")[2].strip()
                    context.execute_steps(u"Given restart uproxy with options '{0}'".format(options))

                if line.find('#!multiline') != -1:
                    is_multiline = True

                continue;

            if is_multiline:
                sql = sql + line + "\n"
            else:
                sql = line

            if (not is_multiline or is_next_line_milestone) and len(sql)>0:
                context.logger.info("is_share_conn: {0}".format(is_share_conn))
                if is_share_conn:
                    context.conn_mysql = getattr(context, mysql_conn_name)
                    context.conn_uproxy = getattr(context, uproxy_conn_name)
                    # connection names such as share_conn_n is closed when a complete sql file is executed over
                    # context.logger.info("is_next_line_milestone:{0}".format(is_next_line_milestone))
                    # context.logger.info("uproxy_conn_name:{0}".format(uproxy_conn_name))
                    to_close = is_next_line_milestone and uproxy_conn_name=="share_conn"
                else:
                    context.conn_mysql, context.conn_uproxy = get_compare_conn(context, default_db)
                    to_close = True
                do_query(context, line_nu, sql, to_close, default_db)
                # This is just for #!share_conn connections
                if is_share_conn and to_close:
                    delattr(context, mysql_conn_name)
                    delattr(context, uproxy_conn_name)
                    # if filename.find("Statement_Syntax.sql") != -1:
                    #     context.execute_steps(u'Then check inuse bconn is "0"')
                sql = ''
                is_multiline = False
    destroy_share_n_conn(context)


@Given('close ssh')
def step_impl(context):
    rmCmd = "rm -rf /tmp/outfile*.txt /tmp/dumpfile.txt"
    hosts = [context.mysql.ip]

    for host in hosts:
        ssh = SSH(host, context.ssh_user, context.ssh_passwd, context)
        ssh.connect()
        ssh.exec_command(rmCmd)
        ssh.close_ssh()
