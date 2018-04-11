import datetime
import os
import re
import logging
import MySQLdb
from behave import *
from hamcrest import *
from lib.DBUtil import DBUtil
from lib.nodes import *

def get_log_linenu(context):
    logpath = get_full_log_path(context)
    cmd = "wc -l %s | awk '{print $1}'" % logpath
    re, sdo, sdr = context.ssh_client.exec_command(cmd)
    context.logger.info("log lines: {0}".format(sdo))
    context.log_linenu = sdo.strip()

def get_full_log_path(context):
    logpath = "{0}/dble/logs/dble.log".format(context.dble_test_config['dble_basepath'])
    context.logger.info("log path: {0}".format(logpath))
    return logpath

def get_read_dest_cmd(context):
    logpath = get_full_log_path(context)
    regIP = "\"[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:[0-9]\{1,5\}\""
    cmd = "sed '1,{0}d' {1}|grep 'routing query to mysqld' | grep -o -e {2}".format(context.log_linenu,logpath, regIP)
    return cmd

@Given('init read-write-split data')
def step_impl(context):
    subdir = context.dble_test_config['result']['dir']+ "/"
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
    m_ip = context.dble_test_config['compare_mysql']['ip']
    m_port = context.dble_test_config['compare_mysql']['port']
    m_user = context.dble_test_config['mysql_user']
    m_passwd = context.dble_test_config['mysql_password']

    conn_mysql = DBUtil(m_ip, m_user, m_passwd, default_db, m_port, context)
    conn_dble = DBUtil(context.dble_test_config['dble_host'], context.dble_test_config['client_user'], context.dble_test_config['client_password'],
                       default_db, context.dble_test_config['client_port'], context)

    return conn_mysql, conn_dble

def destroy_share_n_conn(context):
    for i in range(1,10):
        dble_conn_name = "share_conn_{0}".format(i)
        mysql_conn_name = "{0}_mysql".format(dble_conn_name)
        if hasattr(context, dble_conn_name):
            conn_mycat = getattr(context, dble_conn_name)
            conn_mysql = getattr(context, mysql_conn_name)
            conn_mycat.close()
            conn_mysql.close()
            delattr(context, dble_conn_name)
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
            context.conn_dble.autocommit(False)

        result1, err1 = context.conn_mysql.query(sql)
        result2, err2 = context.conn_dble.query(sql)

        if reset_autocommit:
            context.conn_mysql.autocommit(True)
            context.conn_dble.autocommit(True)

        context.logger.info("compare sql result:")
        compare_result(context, line_nu, sql, result1, result2, err1, err2)
        context.logger.info("toClose is : {0}".format(to_close))
        if to_close:
            context.conn_mysql.close()
            context.conn_dble.close()
            context.conn_mysql = None
            context.conn_dble = None
    return result2

def compare_result(context, id, sql, mysql_result, dble_result, err1, err2):
    if len(sql)>1000: sql = "{0}...{1}".format(sql[0:300], sql[-50:])
    c = re.compile(r'\/\*\s*allow_diff\s*\*\/')
    d = re.search(c, sql)
    isAllowDiff = d is not None
    isNoErr = err1 is None and err2 is None

    isResultSame = isNoErr and isAllowDiff

    if type(dble_result) == tuple and type(mysql_result) == tuple:
        if (sql.find('order by') != -1) or (sql.find('group by') != -1):
            context.logger.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{0}".format(sql))
            context.logger.info("dble:{0}".format(dble_result))
            context.logger.info("mysql:{0}".format(mysql_result))
            result1 = tuple(dble_result)
            result2 = tuple(mysql_result)
        else:
            result1 = sorted(tuple(dble_result))
            result2 = sorted(tuple(mysql_result))
        isResultSame = len(result1) == len(result2) or dble_result == mysql_result or (isNoErr and isAllowDiff)

    dble_re = "dble:[" + str(dble_result) +"]\n"
    mysql_re = "mysql:[" + str(mysql_result) +"]\n"

    if not hasattr(context, 'sql_file'):
        context.sql_file = "lock.sql"

    if(isResultSame):
        context.logger.info("isResultSame is true, but err may be different")
        if isNoErr:
            with open(context.cur_pass_log, 'a') as fpT:
                fpT.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
                if isAllowDiff:
                    fpT.writelines(dble_re)
                    fpT.writelines(mysql_re)
            context.logger.info("mysql_err == null && dble_err == null")
        else:
            if err1 is None:
                isMysqlSynErr = None
            else:
                isMysqlSynErr = err1[1].find('You have an error in your SQL syntax') != -1
            if err2 is None:
                isMycatSynErr = None
            else:
                isMycatSynErr = err2[1].find('Syntax error or unsupported sql by uproxy') != -1
            if err1 == err2 or (isMysqlSynErr and isMycatSynErr):
                log_file = context.cur_warn_log
            else:
                log_file = context.cur_serious_warn_log

            with open(log_file, 'a') as fpW:
                fpW.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id,sql, context.sql_file))
                fpW.writelines("mysql err:{0}\n".format(err1))
                fpW.writelines("dble err[{1}] :{0}\n".format(err2, datetime.datetime.now().strftime('%H:%M:%S.%f')))

            context.logger.info("mysql_err: {0}".format(err1))
            context.logger.info("dble_err: {0}".format(err2))
    else:
        with open(context.cur_fail_log, 'a') as fpF:
            fpF.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id,sql, context.sql_file))
            reMysql = "mysql:[" + str(mysql_result) +"]\n"
            fpF.writelines(dble_re)
            fpF.writelines(reMysql)

            if err1 is not None:
                fpF.writelines("mysql err:{0}\n".format(err1))
            if err2 is not None:
                fpF.writelines("[{1}]dble err :{0}\n".format(err2, datetime.datetime.now().strftime('%H:%M:%S.%f')))
        context.logger.info("isResultSame false.")

def check_sql_dest(context,line_nu, sql):
    """
    check sql is sent to the right destination server by dble
    find destination by line 'routing query to mysqld ip:port'
    """
    import re
    node = '/dn[1,2,3,4]/='
    nodenum = 0
    sql_cmd = []

    context.logger.info("sql route send compare ")

    if re.search(r'\/\*\s*1\s*\*\/', sql):
        nodenum = 1
        sql_cmd = re.sub(r'\/\*\s*1\s*\*\/','',sql)
    elif re.search(r'\/\*\s*1_2\s*\*\/', sql):
        nodenum = 2
        sql_cmd = re.sub(r'\/\*\s*1_2\s*\*\/','', sql)
        flag = '\/\*\s*1_2\s*\*\/'
    elif re.search(r'\/\*\s*1_2_3\s*\*\/', sql):
        nodenum = 3
        sql_cmd = re.sub(r'\/\*\s*1_2_3\s*\*\/','', sql)
    elif re.search(r'\/\*\s*1_2_3_4\s*\*\/', sql):
        nodenum = 4
        sql_cmd = re.sub(r'\/\*\s*1_2_3_4\s*\*\/','', sql)
    else:
        context.logger.info("sql value is : {0}".format(sql))
        context.logger.info("nodenum value is : {0}".format(nodenum))

    #log = '{0}'.format(context.mycat.item)
    logpath = "{0}/dble/logs/dble.log".format(context.dble_test_config['dble_basepath'])
    sr = "/route={/,/} rrs/"


    if re.search(r'insert',sql,flags=re.IGNORECASE):
        sql1='INSERT'
    elif re.search(r'update',sql,flags=re.IGNORECASE):
        sql1='UPDATE'
    elif re.search(r'delete',sql,flags=re.IGNORECASE):
        sql1='DELETE'
    elif re.search(r'select',sql,flags=re.IGNORECASE):
        sql1='SELECT'
    else:
        sql1 = str(sql_cmd).strip('\n')

    cmd1 = "sed '1,{0}d' {1}|sed -n '{2}'p |sed -n '/{3}/p' | sed -n '{4}'".format(context.log_linenu,logpath,sr,sql1, node)
    rc, stdout, stderr = context.ssh_client.exec_command(cmd1)
    assert_that(stderr, is_(" "))
    sum = 0
    for i in stdout.readlines():
        sum +=1
    with open(context.cur_route_log, 'a') as fpT:
        if sum != nodenum:
            fpT.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(line_nu, sql.strip('\n'), context.sql_file))
            fpT.writelines("expect route number:{0},tesing route number:{1} \n".format(nodenum,sum))
            context.logger.info("route err")
    assert_that(sum, equal_to(nodenum))

@Then('execute sql in "{filename}" to check read-write-split work fine and log dest slave')
def step_impl(context, filename):
    context.sql_file = filename
    context.execute_steps(u'Given init read-write-split data')

    filepath = "sqls/{0}".format(filename)
    sql = ''
    is_multiline = False
    is_share_conn = False
    with open(filepath) as fp:
        lines = fp.readlines()
        total_lines = len(lines)
        line_nu = 0
        default_db = "mytest"
        step_len = 1;
        next_line = lines[0].strip()
        for idx in range(0, total_lines):
            if line_nu > idx: continue
            line = next_line
            line_nu += step_len
            is_next_line_exist = line_nu < total_lines
            if is_next_line_exist:
                step_len = 1
                next_line = lines[line_nu].strip()
                while is_next_line_exist and len(next_line) == 0:
                    next_line_nu = line_nu + step_len
                    is_next_line_exist = next_line_nu < total_lines
                    if is_next_line_exist:
                        next_line = lines[next_line_nu].strip()
                        step_len += 1

            is_next_line_milestone = (not is_next_line_exist) or next_line.startswith("#")

            context.logger.info("********* {2} line {1}: {0} **********".format(line, line_nu, filename))
            if line.startswith('#'):
                is_share_conn = False
                if line.find('#!share_conn') != -1:
                    r = re.search('share_conn_?\d*', line)
                    uproxy_conn_name = r.group()
                    mysql_conn_name = "{0}_mysql".format(uproxy_conn_name)
                    if not hasattr(context, uproxy_conn_name):
                        conn_mysql, conn_dble = get_compare_conn(context, default_db)
                        setattr(context, uproxy_conn_name, conn_dble)
                        setattr(context, mysql_conn_name, conn_mysql)
                    is_share_conn = True

                elif line.startswith('#!restart-mysql'):
                    options = line.partition("::")[2].strip()
                    context.execute_steps(
                        u'Given restart mysql with options "{0}" and reconnect success'.format(options))
                elif line.startswith('#!restart-dble'):
                    options = line.partition("::")[2].strip()
                    context.execute_steps(u"Given restart uproxy with options '{0}'".format(options))

                if line.find('#!multiline') != -1:
                    is_multiline = True

                if line.find("#end multiline") != -1 and len(sql) == 0:
                    is_multiline = False

                continue;

            if is_multiline:
                sql = sql + line + "\n"
            else:
                sql = line

            if (not is_multiline or is_next_line_milestone) and len(sql) > 0:
                context.logger.info("is_share_conn: {0}".format(is_share_conn))
                if is_share_conn:
                    context.conn_mysql = getattr(context, mysql_conn_name)
                    context.conn_dble = getattr(context, uproxy_conn_name)
                    # connection names such as share_conn_n is closed when a complete sql file is executed over
                    # context.logger.info("is_next_line_milestone:{0}".format(is_next_line_milestone))
                    # context.logger.info("uproxy_conn_name:{0}".format(uproxy_conn_name))
                    to_close = is_next_line_milestone and uproxy_conn_name == "share_conn"
                else:
                    context.conn_mysql, context.conn_dble = get_compare_conn(context, default_db)
                    to_close = True
                do_query(context, line_nu, sql, to_close)

                if re.search(r'route', str(context.sql_file)):
                    check_sql_dest(context, line_nu, sql)

                # This is just for #!share_conn connections
                if is_share_conn and to_close:
                    delattr(context, mysql_conn_name)
                    delattr(context, uproxy_conn_name)
                sql = ''
                is_multiline = False
    destroy_share_n_conn(context)

def connect_test(context, ip, user, passwd, port):
    conn = None
    isSuccess = False
    max_try=5
    while conn is None:
        try:
            conn = DBUtil(ip, user, passwd,'', port, context)
        except MySQLdb.Error,e:
            context.logger.info("connect to {0} err:{1}".format(ip, e))
            conn = None
        finally:
            max_try -= 1
            if max_try == 0 and conn is None: break
            if conn is not None:
                isSuccess = True
                conn.close()

        context.execute_steps(u'Given sleep "60" seconds')

    assert_that(isSuccess, "can not connect to {0} after 5 minutes wait".format(ip))

@Given('clear dirty data yield by sql')
def step_impl(context):
    pass
    # rmCmd = "rm -rf /tmp/outfile*.txt /tmp/dumpfile.txt"
    # hosts = [context.mysql.ip]
    #
    # for host in hosts:
    #     ssh = SSH(host, context.ssh_user, context.ssh_passwd, context)
    #     ssh.connect()
    #     ssh.exec_command(rmCmd)
    #     ssh.close_ssh()


@When('compare results with the standard results')
def step_impl(context):
    import subprocess
    exit_code = subprocess.call(["bash" ,"compare_result.sh"])
    assert_that(exit_code, equal_to(0), "result is different with standard")
    context.logger.info("read write split pass")
