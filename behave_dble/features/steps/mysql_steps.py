# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM1:35
# @Author  : irene-coming
import logging
import os.path
from threading import Thread

from steps.lib.utils import get_node, wait_for, sleep_by_time
from steps.lib.Flag import Flag
from steps.lib.DbleObject import DbleObject
from steps.lib.PostQueryCheck import PostQueryCheck
from steps.lib.PreQueryPrepare import PreQueryPrepare
from steps.lib.QueryMeta import QueryMeta
from steps.lib.ObjectFactory import ObjectFactory
from behave import *
import time
from datetime import datetime

global sql_threads
sql_threads = []

global tcpdump_threads
tcpdump_threads = []

global jstack_threads
jstack_threads = []

logger = logging.getLogger('root')


def check_tcpdump_pid_exist(sshClient):
    cmd = "ps aux|grep tcpdump| grep -v grep | awk '{print $2}' | wc -l"
    rc, sto, ste = sshClient.exec_command(cmd)
    assert len(ste) == 0, "exec cmd fail for:{0}".format(ste)
    tcpdump_pid_exist = str(sto) == '1'
    logger.debug("check tcpdump pid exists.")
    return tcpdump_pid_exist

    # tcpdump   9925  9508  1 10:54 ?        00:00:00 tcpdump -w /tmp/tcpdump.log

def check_tcpdump_file_exist(sshClient,file):
    filepath, filename = os.path.split(file)
    cmd = "find {} -name {}".format(filepath,filename)
    rc, sto, ste = sshClient.exec_command(cmd)
    assert len(ste) == 0, "exec cmd {} fail for:{}".format(cmd,ste)
    tcpdump_file_exist = len(sto) != 0
    logger.debug("check tcpdump file exists.")
    return tcpdump_file_exist


def stop_tcpdump(context, sshClient):
    cmd = "kill -SIGINT `ps aux | grep tcpdump |grep -v bash|grep -v grep| awk '{{print $2}}'`"
    rc, sto, ste = sshClient.exec_command(cmd)
    assert len(ste) == 0, "kill tcpdump err:{0}".format(ste)

    # make sure the tcpdump stop success
    @wait_for(context, text="stop tcpdump failed!", duration=5, interval=0.5)
    def check_tcpdump_stopped(sshClient):
        if not check_tcpdump_pid_exist(sshClient):
            return True
        return False
    check_tcpdump_stopped(sshClient)
    logger.debug("tcpdump stop success")

@Given('prepare a thread to run tcpdump in "{host}"')
def step_impl(context, host):
    node = get_node(host)
    sshClient = node.ssh_conn
    run_tcpdump_cmd = context.text.strip()
    file = run_tcpdump_cmd.split()[-1]
    if check_tcpdump_pid_exist(sshClient):
        stop_tcpdump(context, sshClient)

    current_datetime = datetime.strftime(datetime.now(), '%H%M%S_%f')
    tcpdump_thread_name = "tcpdump_{0}".format(current_datetime)
    context.logger.debug("tcpdump_thread_name: {0}".format(tcpdump_thread_name))
    global tcpdump_threads
    thd = Thread(target=run_tcpdump, args=(sshClient, run_tcpdump_cmd), name=tcpdump_thread_name)
    tcpdump_threads.append(thd)

    thd.setDaemon(True)
    thd.start()

    # make sure the tcpdump start success
    @wait_for(context, text="start tcpdump failed!", duration=5, interval=0.5)
    def check_tcpdump_started(sshClient):
        if check_tcpdump_pid_exist(sshClient):
            return True
        return False
    check_tcpdump_started(sshClient)

    # make sure the tcpdump works
    @wait_for(context, text="tcpdump does not work in 30 seconds!", duration=30, interval=1)
    def check_tcpdump_works(sshClient,file):
        if check_tcpdump_file_exist(sshClient,file):
            return True
        return False
    check_tcpdump_works(sshClient,file)


def run_tcpdump(sshClient, run_tcpdump_cmd):
    rc, sto, ste = sshClient.exec_command(run_tcpdump_cmd, timeout=300)
    logger.debug("tcpdump cmd is: {0}".format(run_tcpdump_cmd))
    assert len(ste) == 0, "tcpdump err:{0}".format(ste)


@Given('stop and destroy tcpdump threads list in "{host}"')
def destroy_threads(context, host):
    node = get_node(host)
    sshClient = node.ssh_conn
    if check_tcpdump_pid_exist(sshClient):
        stop_tcpdump(context, sshClient)
        global tcpdump_threads
        if len(tcpdump_threads) > 0:
            for thd in tcpdump_threads:
                logger.debug("join tcpdump thread: {0}".format(thd.name))
                thd.join()
            tcpdump_threads = []
        # 由于ci环境权限限制，现在改成写入到/tmp目录下
        mv_cmd = "mv /tmp/*.log /opt/dble/logs"
        rc, sto, ste = sshClient.exec_command(mv_cmd)
        assert len(ste) == 0, "mv tcpdump file err:{0}".format(ste)


@Given('restart mysql in "{host_name}" with sed cmds to update mysql config')
@Given('restart mysql in "{host_name}"')
def restart_mysql(context, host_name, sed_str=None):
    if not sed_str and context.text is not None and len(context.text) > 0:
        sed_str = context.text

    mysql = ObjectFactory.create_mysql_object(host_name)
    # this is temp for debug stop mysql fail
    execute_sql_in_host(host_name, {'sql': 'show processlist'})
    # end debug stop mysql fail
    mysql.restart(sed_str)


@Given('stop mysql in host "{host_name}"')
def stop_mysql(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)

    # this is temp for debug stop mysql fail
    execute_sql_in_host(host_name, {'sql': 'show processlist'})
    # end debug stop mysql fail

    mysql.stop()


@Given('start mysql in host "{host_name}"')
def start_mysql(context, host_name, sed_str=None):
    if not sed_str and context.text is not None and len(context.text) > 0:
        sed_str = context.text

    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.start(sed_str)


@Given('turn on general log in "{host_name}"')
def step_impl(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.turn_on_general_log()


@Given('turn off general log in "{host_name}"')
def turn_off_general_log(context, host_name):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.turn_off_general_log()


@Then('check general log in host "{host_name}" has not "{query}"')
def step_impl(context, host_name, query):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.check_query_in_general_log(query, expect_exist=False)


@Then('check general log in host "{host_name}" has "{query}"')
@Then('check general log in host "{host_name}" has "{query}" occured "{occur_times_expr}" times')
def step_impl(context, host_name, query, occur_times_expr=None):
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.check_query_in_general_log(query, expect_exist=True, expect_occur_times_expr=occur_times_expr)


@Given('execute sql in "{host_name}"')
@Then('execute sql in "{host_name}"')
def step_impl(context, host_name):
    for row in context.table:
        execute_sql_in_host(host_name, row.as_dict())


def execute_sql_in_host(host_name, info_dic, mode="mysql"):
    if mode in ["admin", "user"]:  # query to dble
        obj = ObjectFactory.create_dble_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._dble_meta)
    else:
        obj = ObjectFactory.create_mysql_object(host_name)
        query_meta = QueryMeta(info_dic, mode, obj._mysql_meta)

    pre_delegater = PreQueryPrepare(query_meta)
    pre_delegater.prepare()

    if not info_dic.get("timeout"):
        timeout = 1
    elif "," in info_dic.get("timeout"):
        timeout=int(info_dic.get("timeout").split(",")[0])
        sep_time=float(info_dic.get("timeout").split(",")[1])
    else:
        timeout=int(info_dic.get("timeout"))
        sep_time=1

    for i in range(timeout):
        try:
            res, err, time_cost = obj.do_execute_query(query_meta)
            post_delegater = PostQueryCheck(res, err, time_cost, query_meta)
            post_delegater.check_result()
            break
        except Exception as e:
            logger.info(f"result is not out yet,retry {i} times")
            if i == timeout-1:
                node = get_node(host_name)
                if mode in ["admin", "user"]:  #print dble jstack
                    print_jstack(node)
                    logger.debug(f"print dble jstack end")
                raise e
            else:
                time.sleep(sep_time)
    return res, err


def print_jstack(node):
    ssh_client = node.ssh_conn
    get_dble_pid_cmd = "jps | grep WrapperSimpleApp | awk '{print $1}'"
    rc, sto, ste = ssh_client.exec_command(get_dble_pid_cmd)
    assert len(sto) > 0, "print jstack: dble pid not found!!!"

    current_datetime = datetime.strftime(datetime.now(), '%H%M%S_%f')
    jstack_url = "/opt/dble/logs/jstack_{0}.log".format(current_datetime)
    print_jstack_cmd = "jstack -l {0} > {1}".format(sto, jstack_url)
    ssh_client.exec_command(print_jstack_cmd)
    logger.debug("print jstack finished, {0}".format(jstack_url))


def print_jstack_thread(context, host, sleep_time):
    node = get_node(host)
    context.stop_jstack = False
    while True:
        if context.stop_jstack:
            context.logger.debug("try to stop jstack thread")
            break
        print_jstack(node)
        sleep_by_time(context, sleep_time)


@Given('prepare a thread to run jstack in "{host}" every "{sleep_time}" seconds')
@Given('prepare a thread to run jstack in "{host}"')
def step_impl(context, host, sleep_time=1):
    current_datetime = datetime.strftime(datetime.now(), '%H%M%S_%f')
    thread_name = "jstack_thd_{0}".format(current_datetime)
    context.logger.debug("jstack_thread_name: {0}".format(thread_name))
    global jstack_threads
    thd = Thread(target=print_jstack_thread, args=(context, host, sleep_time), name=thread_name)
    jstack_threads.append(thd)
    thd.setDaemon(True)
    thd.start()


@Given('destroy jstack threads list')
def destroy_jstack_threads(context):
    context.stop_jstack = True
    global jstack_threads
    if len(jstack_threads) > 0:
        for thd in jstack_threads:
            thd.join(3)
            logger.debug("stopped jstack thread: {0}".format(thd.name))
        jstack_threads = []


@Given('execute sql "{num}" times in "{host_name}" at concurrent')
@Given('execute sql "{num}" times in "{host_name}" at concurrent {concur}')
@Given('execute "{mode_name}" sql "{num}" times in "{host_name}" at concurrent')
def step_impl(context, host_name, num, concur="100", mode_name="user"):
    row = context.table[0]
    num = int(num)
    info_dic = row.as_dict()
    concur = min(int(concur), num)

    tasks_per_thread = int(num / concur)
    mod_tasks = num % concur
    timestamp = int(round(time.time() * 1000))

    def do_thread_tasks(host_name, info_dic, base_id, tasks_count, eflag):
        my_dic = info_dic.copy()
        my_dic["conn"] = "concurr_conn_{0}_{1}".format(timestamp, i)
        my_dic["toClose"] = "False"
        last_count = tasks_count - 1
        sql_raw = my_dic["sql"]
        for k in range(int(tasks_count)):
            if k == last_count:
                my_dic["toClose"] = "true"
            id = base_id + k
            my_dic["sql"] = sql_raw.format(id)
            # logger.debug("debug1, my_dic:{}, conn:{}".format(my_dic["sql"], my_dic["conn"]))
            try:
                if mode_name == "admin":
                    execute_sql_in_host(host_name, my_dic, "admin")
                else:
                    execute_sql_in_host(host_name, my_dic, "user")
            except Exception as e:
                eflag.exception = e

    for i in range(concur):
        if i < mod_tasks:
            tasks_count = tasks_per_thread + 1
        else:
            tasks_count = tasks_per_thread
        base_id = i * tasks_per_thread
        thd = Thread(target=do_thread_tasks, args=(host_name, info_dic, base_id, tasks_count, Flag))
        thd.start()
        thd.join()

        if Flag.exception:
            raise Flag.exception


@Given('prepare a thread execute sql "{sql}" with "{conn_type}"')
@Given('prepare a thread execute sql "{sql}" with "{conn_type}" and save resultset in "{result_set}"')
def step_impl(context, sql, conn_type='', result_set=''):
    conn = DbleObject.dble_long_live_conns.get(conn_type, None)
    assert conn, "conn '{0}' is not exists in dble_long_live_conns".format(conn_type)
    global sql_threads
    thd = Thread(target=execute_sql_backgroud, args=(context, conn, sql, result_set), name=sql)
    sql_threads.append(thd)
    thd.setDaemon(True)
    thd.start()


def execute_sql_backgroud(context, conn, sql, result_set):
    sql_cmd = sql.strip()
    res, err = conn.execute(sql_cmd)
    if result_set:
        setattr(context, "{0}_result".format(result_set), res)
        setattr(context, "{0}_err".format(result_set), err)
    else:
        setattr(context, "sql_thread_result", res)
        setattr(context, "sql_thread_err", err)
    logger.debug("execute sql in thread end, res or err has been record in context variables")


@Given('destroy sql threads list')
def step_impl(context):
    global sql_threads
    for thd in sql_threads:
        context.logger.debug("join sql thread: {0}".format(thd.name))
        thd.join()


@Given('kill all backend conns in "{host_name}"')
@Given('kill all backend conns in "{host_name}" except ones in "{exclude_conn_ids}"')
def step_impl(context, host_name, exclude_conn_ids=None):
    if exclude_conn_ids:
        exclude_ids = getattr(context, exclude_conn_ids, None)
    else:
        exclude_ids = []

    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.kill_all_conns(exclude_ids)


@Given('kill mysql conns in "{host_name}" in "{conn_ids}"')
def step_impl(context, host_name, conn_ids):
    conn_ids = getattr(context, conn_ids, None)
    assert len(conn_ids) > 0, "no conns in '{}' to kill".format(conn_ids)
    mysql = ObjectFactory.create_mysql_object(host_name)
    mysql.kill_conns(conn_ids)

@Then('kill the redundant connections if "{current_idle_connections}" is more then expect value "{expect_value}" in "{mysql_host_name}"')
def step_impl(context, mysql_host_name, current_idle_connections,expect_value):
    current_idle_connections = getattr(context, current_idle_connections, None)
    need_to_kill_num = len(current_idle_connections) - int(expect_value)
    if need_to_kill_num > 0:
        mysql = ObjectFactory.create_mysql_object(mysql_host_name)
        mysql.kill_redundant_conns(current_idle_connections, need_to_kill_num)

@Given('execute sql "{num}" times in "{host_name}" together use {concur} connection not close')
@Given('execute "{mode_name}" sql "{num}" times in "{host_name}" together use {concur} connection not close')
def step_impl(context, host_name, num, concur="100", mode_name="user"):
    row = context.table[0]
    num = int(num)
    info_dic = row.as_dict()
    concur = min(int(concur), num)

    tasks_per_thread = int(num / concur)
    mod_tasks = num % concur
    timestamp = int(round(time.time() * 1000))

    def do_thread_tasks(host_name, info_dic, base_id, tasks_count, eflag):
        my_dic = info_dic.copy()
        my_dic["conn"] = "concurr_conn_{0}_{1}".format(timestamp, i)
        my_dic["toClose"] = "False"
        last_count = tasks_count - 1
        sql_raw = my_dic["sql"]
        for k in range(int(tasks_count)):
            if k == last_count:
                my_dic["toClose"] = "False"
            id = base_id + k
            my_dic["sql"] = sql_raw.format(id)
            # logger.debug("debug1, my_dic:{}, conn:{}".format(my_dic["sql"], my_dic["conn"]))
            try:
                if mode_name == "admin":
                    execute_sql_in_host(host_name, my_dic, "admin")
                else:
                    execute_sql_in_host(host_name, my_dic, "user")
            except Exception as e:
                eflag.exception = e

    for i in range(concur):
        if i < mod_tasks:
            tasks_count = tasks_per_thread + 1
        else:
            tasks_count = tasks_per_thread
        base_id = i * tasks_per_thread
        thd = Thread(target=do_thread_tasks, args=(host_name, info_dic, base_id, tasks_count, Flag))
        thd.start()
        thd.join()

        if Flag.exception:
            raise Flag.exception


@Then('execute "{mode_name}" sql for "{seconds}" seconds in "{host_name}"')
def step_impl(context, mode_name, seconds, host_name):
    execute_seconds = int(seconds)
    current_time_before_execute = int(time.time())
    while True:
        current_time_in_execute = int(time.time())
        if current_time_in_execute - current_time_before_execute < execute_seconds:
            for row in context.table:
                execute_sql_in_host(host_name, row.as_dict(), mode_name)
        else:
            break
    context.logger.info("execute sql for {0} seconds in {1} complete".format(seconds, host_name))


# delete backend mysql tables from db1 ~ db4
# slave mysql table do not need to delete for reason master mysql table has been deleted
@Given('delete all backend mysql tables')
def delete_all_mysql_tables(context):
    mysql_install_all = ["mysql", "mysql-master1", "mysql-master2", "mysql-master3"]
    databases = ["db1", "db2", "db3", "db4"]
    for mysql_hostname in mysql_install_all:
        for db in databases:
            generate_drop_tables_sql = "select concat('drop table if exists ',table_schema,'.',table_name,';') from information_schema.TABLES where table_schema='{0}'".format(
                db)
            res1, err1 = execute_sql_in_host(mysql_hostname, {"sql": generate_drop_tables_sql}, "mysql")
            assert err1 is None, "general drop table sql failed: {}".format(err1)
            if len(res1) != 0:
                for sql_element in res1:
                    drop_table_sql = sql_element[0]
                    res2, err2 = execute_sql_in_host(mysql_hostname, {"sql": drop_table_sql}, "mysql")
                    assert err2 is None, "execute drop table sql failed: {}".format(err2)
        logger.debug("{0} tables has been delete success".format(mysql_hostname))
    logger.info("all required tables has been delete success")


@given('change the primary instance of mysql group named "{group_name}" to "{hostname}"')
@given('restore mysql replication of the mysql group named "{group_name}" to the initial state')
def step_impl(context, group_name, hostname=""):

    if hostname == "":
        hostname = context.cfg_mysql[group_name]["inst-1"]["hostname"]

    node = get_node(hostname)
    master_ip = node.ip
    master_port = node.mysql_port

    reset_sql = "reset master;stop slave;reset slave all;"
    change_to_new_master = "change master to master_host='{0}', master_port={1},master_user='rsandbox',master_password='rsandbox',master_auto_position=1;".format(master_ip, master_port)
    start_slave = "start slave;"

    execute_sql_in_host(hostname, {"sql": reset_sql})

    for _, info in context.cfg_mysql[group_name].items():
        if info["hostname"] != hostname:
            execute_sql_in_host(info["hostname"], {"sql": reset_sql})
            execute_sql_in_host(info["hostname"], {"sql": change_to_new_master})
            execute_sql_in_host(info["hostname"], {"sql": start_slave})

    logger.info("{0} primary instance has been changed to {1} success".format(group_name, hostname))