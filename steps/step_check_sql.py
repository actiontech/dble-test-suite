import datetime
import os
import shutil
import re
import difflib
from Queue import Queue
from time import sleep

import MySQLdb
from behave import *
from hamcrest import *
from lib.DBUtil import DBUtil
from lib.SqlThread import MyThread
from steps.step_reload import get_dble_conn

global sql_queues
global sql_threads
global sql_res_queues
global last_sql_queue_size
global current_thread_tag
sql_queues = {}
sql_res_queues = {}
sql_threads = {}
last_sql_queue_size = 0
current_thread_tag = []

def get_log_linenu(context):
    logpath = get_full_log_path(context)
    cmd = "wc -l %s | awk '{print $1}'" % logpath
    re, sdo, sdr = context.ssh_client.exec_command(cmd)
    context.logger.info("log lines: {0}".format(sdo))
    context.log_linenu = sdo.strip()


def get_full_log_path(context):
    logpath = "{0}/dble/logs/dble.log".format(context.cfg_dble['install_dir'])
    context.logger.info("log path: {0}".format(logpath))
    return logpath


def get_read_dest_cmd(context):
    logpath = get_full_log_path(context)
    regIP = "\"[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:[0-9]\{1,5\}\""
    cmd = "sed '1,{0}d' {1}|grep 'routing query to mysqld' | grep -o -e {2}".format(context.log_linenu, logpath, regIP)
    return cmd

@Given('set sql cover log dir "{logdir}"')
def step_impl(context, logdir):
    context.cfg_dble['sql_cover_log'] = logdir

@Given('init read-write-split data')
def step_impl(context):
    subdir = context.cfg_dble['sql_cover_log'] + "/"
    if not os.path.exists(subdir):
        os.makedirs(subdir)
    if context.sql_file.find("/") == -1:
        sql_file_name = context.sql_file
    else:
        group = context.sql_file.rpartition("/");
        sql_file_name = group[2]
        subdir = subdir + group[0]
        if not os.path.exists(subdir):
            os.makedirs(subdir)

        subdir = subdir + "/"

    sql_file_name = sql_file_name.split(".")[0]
    context.cur_pass_log = "{0}{1}_pass.log".format(subdir, sql_file_name)
    context.cur_fail_log = "{0}{1}_fail.log".format(subdir, sql_file_name)
    context.cur_warn_log = "{0}{1}_warn.log".format(subdir, sql_file_name)

    if re.search(r'^route', sql_file_name):
        context.cur_route_log = "{0}{1}_send.log".format(subdir, sql_file_name)
    context.cur_serious_warn_log = "{0}/{1}_serious_warn.log".format(subdir, sql_file_name)


def get_compare_conn(context, default_db="schema1"):
    m_ip = context.cfg_mysql['compare_mysql']['master1']['ip']
    m_port = context.cfg_mysql['compare_mysql']['master1']['port']
    m_user = context.cfg_mysql['user']
    m_passwd = context.cfg_mysql['password']

    conn_mysql = DBUtil(m_ip, m_user, m_passwd, default_db, m_port, context)
    conn_dble = get_dble_conn(context, default_db)

    return conn_mysql, conn_dble

def destroy_share_n_conn(context):
    for i in range(1, 10):
        dble_conn_name = "share_conn_{0}".format(i)
        mysql_conn_name = "{0}_mysql".format(dble_conn_name)
        if hasattr(context, dble_conn_name):
            conn_dble = getattr(context, dble_conn_name)
            conn_mysql = getattr(context, mysql_conn_name)
            conn_dble.close()
            conn_mysql.close()
            delattr(context, dble_conn_name)
            delattr(context, mysql_conn_name)


def do_query(context, line_nu, sql, to_close):
    result2 = None
    if len(sql) > 0:
        sql = re.sub("(/*\s*uproxy_dest\s*:\s*)+slave(\d)",
                     lambda x: x.group(1) + context.group1.slaves[int(x.group(2)) - 1], sql)
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
    if len(sql) > 1000: sql = "{0}...{1}".format(sql[0:300], sql[-50:])
    a = re.compile(r'\/\*\s*allow_diff_sequence\s*\*\/')
    b = re.search(a, sql)
    c = re.compile(r'\/\*\s*allow_diff\s*\*\/')
    d = re.search(c, sql)
    e = re.compile(r'\/\*\s*allow_10%_diff\s*\*\/')
    f = re.search(e, sql)
    isAllowDiff = d is not None
    isAllowDiffSequ =b is not None
    isAllowTenDiff = f is not None
    isAllowTen = False
    isNoErr = err1 is None and err2 is None
    g = 0

    isContIndex = True#because of bug:533,temporary plan taken
    if (sql.lower().find('show index') == -1) and (sql.lower().find('show keys') == -1):
        isContIndex = False

    if type(dble_result) == tuple and type(mysql_result) == tuple:
        if (isAllowDiffSequ) or (sql.lower().find('order by') == -1):
            dble_result = sorted(dble_result)
            mysql_result = sorted(mysql_result)

        if (isContIndex or isAllowTenDiff):
            g = difflib.SequenceMatcher(None, str(dble_result), str(mysql_result)).ratio()
            if (g >0.9):
                isAllowTen = True

    isResultSame = dble_result==mysql_result or (isNoErr and isAllowDiff) or (isNoErr and isAllowTen)

    dble_re = "dble:[" + str(dble_result) + "]\n"
    mysql_re = "mysql:[" + str(mysql_result) + "]\n"

    if not hasattr(context, 'sql_file'):
        context.sql_file = "lock.sql"

    if (isResultSame):
        context.logger.info("isResultSame is true, but err may be different")
        if isNoErr:
            with open(context.cur_pass_log, 'a') as fpT:
                fpT.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
                fpT.writelines(dble_re)
                if isAllowDiff:
                    fpT.writelines(mysql_re)
            context.logger.info("mysql_err == null && dble_err == null")
        else:
            if err1 is None:
                isMysqlSynErr = None
            else:
                isMysqlSynErr = err1[1].find('You have an error in your SQL syntax') != -1
            if err2 is None:
                isdbleSynErr = None
            else:
                isdbleSynErr = err2[1].find('Syntax error or unsupported sql by uproxy') != -1
            if err1 == err2 or (isMysqlSynErr and isdbleSynErr):
                log_file = context.cur_warn_log
            else:
                log_file = context.cur_serious_warn_log

            with open(log_file, 'a') as fpW:
                fpW.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
                fpW.writelines("mysql err:{0}\n".format(err1))
                fpW.writelines("dble err[{1}] :{0}\n".format(err2, datetime.datetime.now().strftime('%H:%M:%S.%f')))


            context.logger.info("mysql_err: {0}".format(err1))
            context.logger.info("dble_err: {0}".format(err2))
    else:
        with open(context.cur_fail_log, 'a') as fpF:
            fpF.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(id, sql, context.sql_file))
            reMysql = "mysql:[" + str(mysql_result) + "]\n"
            fpF.writelines(dble_re)
            fpF.writelines(reMysql)

            if err1 is not None:
                fpF.writelines("mysql err:{0}\n".format(err1))
            if err2 is not None:
                fpF.writelines("[{1}]dble err :{0}\n".format(err2, datetime.datetime.now().strftime('%H:%M:%S.%f')))
        context.logger.info("isResultSame false.")


def check_sql_dest(context, line_nu, sql):
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
        sql_cmd = re.sub(r'\/\*\s*1\s*\*\/', '', sql)
    elif re.search(r'\/\*\s*1_2\s*\*\/', sql):
        nodenum = 2
        sql_cmd = re.sub(r'\/\*\s*1_2\s*\*\/', '', sql)
        flag = '\/\*\s*1_2\s*\*\/'
    elif re.search(r'\/\*\s*1_2_3\s*\*\/', sql):
        nodenum = 3
        sql_cmd = re.sub(r'\/\*\s*1_2_3\s*\*\/', '', sql)
    elif re.search(r'\/\*\s*1_2_3_4\s*\*\/', sql):
        nodenum = 4
        sql_cmd = re.sub(r'\/\*\s*1_2_3_4\s*\*\/', '', sql)
    else:
        context.logger.info("sql value is : {0}".format(sql))
        context.logger.info("nodenum value is : {0}".format(nodenum))

    # log = '{0}'.format(context.dble.item)
    logpath = get_full_log_path
    sr = "/route={/,/} rrs/"

    if re.search(r'insert', sql, flags=re.IGNORECASE):
        sql1 = 'INSERT'
    elif re.search(r'update', sql, flags=re.IGNORECASE):
        sql1 = 'UPDATE'
    elif re.search(r'delete', sql, flags=re.IGNORECASE):
        sql1 = 'DELETE'
    elif re.search(r'select', sql, flags=re.IGNORECASE):
        sql1 = 'SELECT'
    else:
        sql1 = str(sql_cmd).strip('\n')

    cmd1 = "sed '1,{0}d' {1}|sed -n '{2}'p |sed -n '/{3}/p' | sed -n '{4}'".format(context.log_linenu, logpath, sr,
                                                                                   sql1, node)
    rc, stdout, stderr = context.ssh_client.exec_command(cmd1)
    assert_that(stderr, is_(" "), "std err {0} is not as expectd empty".format(stderr))
    sum = 0
    for i in stdout.readlines():
        sum += 1
    with open(context.cur_route_log, 'a') as fpT:
        if sum != nodenum:
            fpT.writelines("===file:{2}, id:{0}, sql:[{1}]===\n".format(line_nu, sql.strip('\n'), context.sql_file))
            fpT.writelines("expect route number:{0},tesing route number:{1} \n".format(nodenum, sum))
            context.logger.info("route err")
    assert_that(sum, equal_to(nodenum), "sum: {0} is not equal to nodenum: {1}".format(sum, nodenum))

@Given('rm old logs "{sql_cover_log}" if exists')
def step_impl(context, sql_cover_log):
    if os.path.exists(sql_cover_log):
        shutil.rmtree(sql_cover_log)

@Given('reset replication and none system databases')
def step_impl(context):
    import subprocess
    try:
        out_bytes = subprocess.check_output(['bash', 'compose/resetReplication.sh'])
    except subprocess.CalledProcessError as e:
        out_bytes = e.output  # Output generated before error
        context.logger.info(out_bytes.decode('utf-8'))
    finally:
        context.logger.info(out_bytes.decode('utf-8'))

@Then('execute sql in file "{filename}"')
@Then('execute sql in "{filename}" to check read-write-split work fine and log dest slave')
def step_impl(context, filename):
    context.sql_file = filename
    context.execute_steps(u'Given init read-write-split data')

    filepath = "sqls/{0}".format(filename)
    sql = ''
    is_multiline = False
    is_share_conn = False
    is_sub_thread = False

    global sql_queues
    sql_queues = {}
    with open(filepath) as fp:
        lines = fp.readlines()
        total_lines = len(lines)
        line_nu = 0
        if lines[0].startswith("#!default_db:"):
            default_db = lines[0].split(':')[1]
            default_db = default_db.strip()
        else:
            default_db = context.cfg_sys['default_db']
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

                if line.startswith("#!sql_thread_"):
                    r = re.search('sql_thread_?\d*', line)
                    uproxy_conn_name = r.group()
                    mysql_conn_name = "{0}_mysql".format(uproxy_conn_name)
                    if not hasattr(context, uproxy_conn_name):
                        conn_mysql, conn_dble = get_compare_conn(context, default_db)
                        setattr(context, uproxy_conn_name, conn_dble)
                        setattr(context, mysql_conn_name, conn_mysql)
                    is_sub_thread = True
                elif line.startswith("#!"):
                    is_sub_thread = False

                if line.startswith('#!restart-mysql'):
                    options = line.partition("::")[2].strip()
                    context.execute_steps(
                        u'Given restart mysql with options "{0}" and reconnect success'.format(options))
                elif line.startswith('#!restart-dble'):
                    options = line.partition("::")[2].strip()
                    context.execute_steps(u"Given restart dble with options '{0}'".format(options))

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
                context.logger.info("is_share_conn: {0}, is_sub_thread: {1}".format(is_share_conn, is_sub_thread))
                if is_share_conn:
                    context.conn_mysql = getattr(context, mysql_conn_name)
                    context.conn_dble = getattr(context, uproxy_conn_name)
                    # connection names such as share_conn_n is closed when a complete sql file is executed over
                    # context.logger.info("is_next_line_milestone:{0}".format(is_next_line_milestone))
                    # context.logger.info("uproxy_conn_name:{0}".format(uproxy_conn_name))
                    to_close = is_next_line_milestone and uproxy_conn_name == "share_conn"
                elif is_sub_thread:
                    context.logger.info(
                        "input sql into queue: {2}".format(line_nu, sql, uproxy_conn_name))
                    sql_item = {"line": line_nu, "sql": sql}
                    dble_sql_queue = sql_queues.get(uproxy_conn_name, None)
                    mysql_sql_queue = sql_queues.get(mysql_conn_name, None)
                    if dble_sql_queue is None:
                        dble_sql_queue = Queue()
                        sql_queues[uproxy_conn_name] = dble_sql_queue
                    dble_sql_queue.put(sql_item)

                    if mysql_sql_queue is None:
                        mysql_sql_queue = Queue()
                        sql_queues[mysql_conn_name] = mysql_sql_queue
                    mysql_sql_queue.put(sql_item)

                    is_sql_thread_end = False
                    tmp = next_line
                    tmp_line_nu = line_nu + 1
                    # context.logger.info("zhj debug1, tmp:{0}, tmp_line_nu:{1}".format(tmp, tmp_line_nu))
                    while tmp.startswith("#"):
                        if tmp_line_nu < total_lines:
                            # context.logger.info("zhj debug2")
                            if tmp.startswith("#!sql_thread_"):
                                # context.logger.info("zhj debug3")
                                is_sql_thread_end = True
                                break
                            else:
                                tmp = lines[tmp_line_nu]
                                tmp_line_nu += 1
                                # context.logger.info("zhj debug4, tmp:{0}".format(tmp))
                        else:
                            # context.logger.info("zhj debug5")
                            is_sql_thread_end = True
                            break
                    context.logger.info("is_sql_thread_end: {0}".format(is_sql_thread_end))
                    if not is_next_line_exist or is_sql_thread_end:
                        context.conn_mysql = getattr(context, mysql_conn_name)
                        context.conn_dble = getattr(context, uproxy_conn_name)

                        do_query_in_thread(context, uproxy_conn_name)

                    sql = ''
                    is_multiline = False
                    continue
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
    destroy_sub_threads(context)


def dble_mng_connect_test(context, ip):
    user = context.cfg_dble['manager_user']
    passwd = str(context.cfg_dble['manager_password'])
    port = context.cfg_dble['manager_port']

    conn = None
    isSuccess = False
    max_try = 5
    while conn is None:
        try:
            conn = DBUtil(ip, user, passwd, '', port, context)
        except MySQLdb.Error, e:
            context.logger.info("connect to {0} err:{1}".format(ip, e))
            conn = None
        finally:
            max_try -= 1
            if max_try < 0 and conn is None: break
            if conn is not None:
                isSuccess = True
                conn.close()
                break

        sleep(5)

    assert_that(isSuccess, "connect test to {0}:9066 failed after {1} seconds".format(ip, 5*max_try))
    context.logger.info("create connection to dble 9066 success")

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


@When('compare results in "{real_res}" with the standard results in "{std_res}"')
def step_impl(context,real_res, std_res):
    import subprocess
    try:
        out_bytes = subprocess.check_output(['bash', 'compare_result.sh', std_res, real_res])
    except subprocess.CalledProcessError as e:
        out_bytes = e.output  # Output generated before error
        out_text = out_bytes.decode('utf-8')
        assert False, "result is different with standard, {0}".format(out_text)
    finally:
        context.logger.info(out_bytes.decode('utf-8'))

def do_query_in_thread(context, dble_thread_tag, interval=5):
    global sql_queues
    global last_dble_sql_res_queue
    global last_mysql_sql_res_queue
    global last_sql_queue_size
    global current_thread_tag

    mysql_thd_tag = dble_thread_tag + "_mysql"
    dble_sql_queue = sql_queues.get(dble_thread_tag, None)
    mysql_sql_queue = sql_queues.get(mysql_thd_tag, None)
    sql_queue_size = dble_sql_queue.qsize()

    context.logger.info("dble sql queues for session {0}: {1}".format(dble_thread_tag, dble_sql_queue.queue))
    context.logger.info("mysql sql queues for session {0}: {1}".format(mysql_thd_tag, mysql_sql_queue.queue))

    if dble_sql_queue is None:
        assert False, "sql queue: {0} is expected, but none".format(dble_thread_tag)
    if mysql_sql_queue is None:
        assert False, "sql queue: {0} is expected, but none".format(mysql_thd_tag)

    get_log_linenu(context)

    prelen = len("sql_thread_")
    current_thread_tag.insert(0,dble_thread_tag[prelen:])
    current_thread_tag.insert(1, mysql_thd_tag[prelen:])

    context.logger.info("current_thread_tag: {0}".format(current_thread_tag))

    # dble thread
    dble_sql_res_queue = sql_res_queues.get(dble_thread_tag, None)
    if dble_sql_res_queue is None:
        context.logger.info("create dble_sql_res_queue")
        dble_sql_res_queue = Queue()
        sql_res_queues[dble_thread_tag] = dble_sql_res_queue

    thd_dble = sql_threads.get(dble_thread_tag, None)
    if thd_dble is None:
        context.logger.info("create dble thread: {0}".format(dble_thread_tag))
        thd_dble = MyThread(dble_thread_tag, context.conn_dble.query, dble_sql_queue, dble_sql_res_queue, current_thread_tag)
        sql_threads[dble_thread_tag] = thd_dble
        thd_dble.start()

    # mysql thread
    mysql_sql_res_queue = sql_res_queues.get(mysql_thd_tag, None)
    if mysql_sql_res_queue is None:
        context.logger.info("create mysql_sql_res_queue")
        mysql_sql_res_queue = Queue()
        sql_res_queues[mysql_thd_tag] = mysql_sql_res_queue

    thd_mysql = sql_threads.get(mysql_thd_tag, None)
    if thd_mysql is None:
        context.logger.info("create mysql thread: {0}".format(mysql_thd_tag))
        thd_mysql = MyThread(mysql_thd_tag, context.conn_mysql.query, mysql_sql_queue, mysql_sql_res_queue, current_thread_tag)
        sql_threads[mysql_thd_tag] = thd_mysql
        thd_mysql.start()

    max_wait_time = sql_queue_size * interval
    time_passed=0
    time_step = 2
    while time_passed < max_wait_time:
        time_passed += time_step
        if dble_sql_res_queue.qsize() <  sql_queue_size or mysql_sql_res_queue.qsize() < sql_queue_size:
            sleep(time_step)
            context.logger.info("timepassed:{0}, try sleep {1}s to wait sql execute".format(time_passed, time_step))
        else:
            break

    if last_sql_queue_size > 0:
        context.logger.info("last_sql_queue_size > 0, last queue is blocked!")
        blocked_sql_num = last_sql_queue_size - last_dble_sql_res_queue.qsize()
        max_wait_time = blocked_sql_num*interval
        time_passed = 0
        time_step = 2
        while time_passed < max_wait_time:
            time_passed += time_step
            if last_dble_sql_res_queue.qsize() < last_sql_queue_size or last_mysql_sql_res_queue.qsize() < last_sql_queue_size:
                sleep(time_step)
                context.logger.info("timepassed:{0}, try sleep {1}s to wait blocked sql execute".format(time_passed, time_step))
            else:
                break

        if last_sql_queue_size == last_dble_sql_res_queue.qsize() and last_dble_sql_res_queue.qsize() == last_mysql_sql_res_queue.qsize():
            deal_result(context, last_dble_sql_res_queue, last_mysql_sql_res_queue)
        else:
            context.logger.info("current session sqls are all executed, but the last session still unfinished!")
            destroy_sub_threads(context)
            assert False, "current session sqls are all executed, but the last session still unfinished!"

        last_sql_queue_size = 0

    context.logger.info(
        "dble_sql_res_queue.qsize(): {0}, mysql_sql_res_queue.qsize(): {1}, sql_queue_size: {2}".format(dble_sql_res_queue.qsize(), mysql_sql_res_queue.qsize(),sql_queue_size))
    if dble_sql_res_queue.qsize() == sql_queue_size and mysql_sql_res_queue.qsize() == sql_queue_size:
        context.logger.info("current queue is unblocked!")
        deal_result(context, dble_sql_res_queue, mysql_sql_res_queue)
    else:
        if last_sql_queue_size !=0 :
            destroy_sub_threads(context)
            assert False, "current session is blocked, but the last session still not finished"

        context.logger.info("current queue is blocked!")
        last_dble_sql_res_queue = dble_sql_res_queue
        last_mysql_sql_res_queue = mysql_sql_res_queue
        last_sql_queue_size = sql_queue_size


def deal_result(context, dble_sql_res_queue, mysql_sql_res_queue):
    while dble_sql_res_queue.qsize() > 0:
        dble_item = dble_sql_res_queue.get()
        mysql_item = mysql_sql_res_queue.get()
        dble_result = dble_item.get("res")
        dble_err = dble_item.get("err")
        mysql_result = mysql_item.get("res")
        mysql_err = mysql_item.get("err")
        line = mysql_item.get("line")
        sql = mysql_item.get("sql")

        context.logger.info("compare cross thread of line:{0} sql: {1}:".format(line, sql))
        compare_result(context, line, sql, mysql_result, dble_result, mysql_err, dble_err)

def destroy_sub_threads(context):
    context.logger.info("destroy sql threads")
    global sql_threads
    global sql_res_queues
    global current_thread_tag

    current_thread_tag.insert(0, -1)
    if sql_threads is not None:
        for thread_tag in sql_threads:
            thd = sql_threads.get(thread_tag, None)
            if thd is not None:
                context.logger.info("sql threads to join:{0}".format(thread_tag))
                thd.join()
        sql_threads.clear()

    context.logger.info("all sql threads join over!")
    if sql_res_queues is not None:
        sql_res_queues.clear()

    while len(current_thread_tag)>0:
        current_thread_tag.pop()
