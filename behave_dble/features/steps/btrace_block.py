# -*- coding: utf-8 -*-
# @Time    : 2019/6/25 AM10:56
# @Author  : zhaohongjie@actionsky.com
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

from threading import Thread, Condition

import time

from behave import *

from steps.lib.QueryMeta import QueryMeta
from steps.lib.utils import get_sftp, get_ssh, get_node, wait_for, sleep_by_time
from steps.mysql_steps import print_jstack
import logging
logger = logging.getLogger('root')

global btrace_threads
btrace_threads = []

def check_btrace_running(sshClient, btraceScript):
    cmd = "ps -ef |grep btrace|grep -v -w grep| grep -F -c {0}".format(btraceScript)
    rc, sto, ste = sshClient.exec_command(cmd)
    logger.debug("check btrace is running with cmd {}, and its sto is:{}".format(cmd,sto))
    return int(sto) == 3

    # sto==3, because btrace ps will show like:
    # root     20437 16921  0 15:21 ?        00:00:00 bash -c btrace -v -o /opt/dble/newConnectionBorrow1.java.log 20283 /opt/dble/newConnectionBorrow1.java >>/opt/dble/newConnectionBorrow1.java.log
    # root     20440 20437  0 15:21 ?        00:00:00 /bin/sh /opt/btrace/bin/btrace -v -o /opt/dble/newConnectionBorrow1.java.log 20283 /opt/dble/newConnectionBorrow1.java
    # root     20444 20440 78 15:21 ?        00:00:00 /opt/jdk/bin/java -Dcom.sun.btrace.unsafe=true -cp /opt/btrace/build/btrace-client.jar:/opt/jdk/lib/tools.jar:/usr/share/lib/java/dtrace.jar com.sun.btrace.client.Main -v -o /opt/dble/newConnectionBorrow1.java.log 20283 /opt/dble/newConnectionBorrow1.java

def stop_btrace(sshClient, btraceScript):
    # 由于有些(集群)case会先kill dble的进程及守护进程，从而导致btrace进程也会被kill掉
    # 所以改成能kill空集的方式，或者先判断pid存在再kill(此处选择后者)
    isBtraceRunningSuccess = check_btrace_running(sshClient, btraceScript)
    if isBtraceRunningSuccess:
        # 集群中还需要过滤掉zk的干扰
        cmd = "kill -SIGINT `jps | grep Main |grep -v QuorumPeerMain| awk '{{print $1}}'`"
        rc, sto, ste = sshClient.exec_command(cmd)
        assert len(ste) == 0, "kill btrace err:{0}".format(ste)
    time.sleep(5)


def run_btrace_script(sshClient, btraceScript):
    getDblePidCmd = "jps | grep WrapperSimpleApp | awk '{print $1}'"
    rc, sto, ste = sshClient.exec_command(getDblePidCmd)
    assert len(sto) > 0, "dble pid not found!!!"

    # {0}:btrace file with dir,{1}:btrace file, {2}:dble pid
    cmd = "btrace -v -o {0}.log {1} {0} >>{0}.log".format(btraceScript, sto)
    rc, sto, ste = sshClient.exec_command(cmd, timeout=300)
    assert len(ste) == 0, "btrace err:{0}".format(ste)


@Given('prepare a thread run btrace script "{btraceScript}" in "{host}"')
def step_impl(context, btraceScript, host):
    node = get_node(host)
    sshClient = node.ssh_conn

    isBtraceRunning = check_btrace_running(sshClient, btraceScript)
    context.logger.info("isBtraceRunning:{0} before try to run {1}".format(isBtraceRunning, btraceScript))
    if not isBtraceRunning:
        sftpClient = get_sftp(host)
        localFile = "assets/{0}".format(btraceScript)
        remoteFile = "{0}/dble/{1}".format(node.install_dir, btraceScript)
        sftpClient.sftp_put(localFile, remoteFile)

        global btrace_threads
        thd = Thread(target=run_btrace_script, args=(sshClient, remoteFile), name=btraceScript)
        btrace_threads.append(thd)

        thd.setDaemon(True)
        thd.start()

        # make sure the btrace is running
        check_btrace_pid_count = 0
        isBtraceRunningSuccess=check_btrace_running(sshClient, remoteFile)
        if not isBtraceRunningSuccess:
            while check_btrace_pid_count < 5:
                time.sleep(2)
                check_btrace_pid_count = check_btrace_pid_count + 1
                isBtraceRunningSuccess=check_btrace_running(sshClient, remoteFile)
                if isBtraceRunningSuccess:
                    break
            assert isBtraceRunningSuccess, "btrace {} is not running in {} seconds,isBtraceRunningSuccess is {}".format(btraceScript, check_btrace_pid_count * 2,isBtraceRunningSuccess)

        # make sure the btrace is working
        @wait_for(context, text="start btrace failed! btrace is not working", duration=15, interval=0.5)
        def check_btrace_working(sshClient, remoteFile):
            cmd = "grep OkayCommand {}.log |wc -l".format(remoteFile)
            rc, sto, ste = sshClient.exec_command(cmd)
            logger.debug("grep cmd is: {}, and its sto is {}".format(cmd, sto))
            assert len(ste) == 0, "expect execute cmd {} success, but outcome with err:{}".format(cmd, ste)
            if int(sto) >= 2:
                return True
            else:
                logtext = "cat {}.log".format(remoteFile)
                rc, sto, ste = sshClient.exec_command(logtext)
                logger.debug("logtext:{0}".format(sto))
            return False
        check_btrace_working(sshClient, remoteFile)

@Given('execute sqls in "{host}" at background')
def step_impl(context, host):
    node = get_node(host)
    sshClient = node.ssh_conn

    context.logger.debug("btrace is running, start query!!!")
    # time.sleep(5)
    for row in context.table:
        query_meta = QueryMeta(row.as_dict(), "user", node)
        cmd = u"nohup mysql -u{} -p{} -P{} -c -D{} -h{} -e'{}' >/opt/dble/logs/dble_user_query.log 2>&1 &".format(query_meta.user,query_meta.passwd,query_meta.port,query_meta.db,query_meta.ip,query_meta.sql)
        rc, sto, ste = sshClient.exec_command(cmd)
        assert len(ste) == 0, "impossible err occur"


def check_btrace_output(sshClient, btraceScript, expectTxt, context, num_expr):
    retry = 0
    isFound = False
    while retry < 30:
        time.sleep(2)  # a interval wait for query run into
        cmd = "cat {0}.log | grep -o '{1}' | wc -l".format(btraceScript, expectTxt)
        rc, sto, ste = sshClient.exec_command(cmd)
        logger.debug("grep cmd is: {}".format(cmd))
        assert len(ste) == 0, "btrace err:{0}".format(ste)
        isFound_str = "{}{}".format(sto, num_expr)
        isFound = eval(isFound_str)
        if isFound:
            context.logger.debug("query blocked by btrace is found in {0}s".format((retry + 1) * 2))
            break

        retry = retry + 1

    assert isFound, "expect find text '{0}' in {1}.log with {2} times, but real is {3} ".format(expectTxt, btraceScript, num_expr, sto)


@Then('check btrace "{btraceScript}" output in "{host}" with "{num_expr}" times')
@Then('check btrace "{btraceScript}" output in "{host}"')
def step_impl(context, btraceScript, host, num_expr="==1"):
    node = get_node(host)
    sshClient = node.ssh_conn
    remoteFile = "{0}/dble/{1}".format(node.install_dir, btraceScript)

    try:
        int(num_expr)
        num_expr = "=={}".format(num_expr)
    except Exception as e:
        context.logger.debug("num already in expr")

    check_btrace_output(sshClient, remoteFile, context.text.strip(), context, num_expr)


def kill_query(sshClient, query, context):
    cmd = u"kill -9 `ps -ef | grep -F '{0}'| grep -v grep | awk '{{print $2}}'`".format(query)
    rc, sto, ste = sshClient.exec_command(cmd)
    assert len(ste) == 0, "kill query client failed for: {0}".format(ste)


@Given('kill mysql query in "{host}" forcely')
def step_impl(context, host):
    sshClient = get_ssh(host)

    kill_query(sshClient, context.text, context)


@Given('stop btrace script "{btraceScript}" in "{host}"')
def step_impl(context, btraceScript, host):
    sshClient = get_ssh(host)

    isBtraceRunning = check_btrace_running(sshClient, btraceScript)
    context.logger.info("isBtraceRunning:{0} before try to stop {1}".format(isBtraceRunning, btraceScript))
    if isBtraceRunning:
        stop_btrace(sshClient, btraceScript)


@Given('destroy btrace threads list')
def destroy_threads(context):
    global btrace_threads
    for thd in btrace_threads:
        context.logger.debug("join btrace thread: {0}".format(thd.name))
        thd.join()
    btrace_threads = []


@Then('check sql thread output in "{result}" by retry "{retry_param}" times')
@Then('check sql thread output in "{result}"')
def check_sql_thread(context, result, retry_param=1):
    if "," in str(retry_param):
        retry_times = int(retry_param.split(",")[0])
        sep_time = float(retry_param.split(",")[1])
    else:
        retry_times = int(retry_param)
        sep_time = 1

    text_info = context.text.strip()
    execute_times = retry_times + 1
    for i in range(execute_times):
        try:
            if result.lower() == "res":
                output = getattr(context, "sql_thread_result")
                context.logger.debug("sql thread output from res: {0}".format(output))
            elif result.lower() == "err":
                output = getattr(context, "sql_thread_err")
                context.logger.debug("sql thread output from err: {0}".format(output))
            else:
                output = getattr(context, result.lower())
                context.logger.debug("sql thread output from result set: {0}".format(output))

            if text_info.rfind("//") > -1:
                expect = text_info.split("//")
                for x in expect:
                    if str(output).find(x.strip()) > -1:
                        text_info = x.strip()
                        break
            assert str(output).find(text_info) > -1, "expect output: {0} in {1}, but was: {2}".format(context.text, result, output)
            break
        except Exception as e:
            logger.info(f"sql thread result is not out yet, execute {i + 1} times")
            if i == execute_times - 1:
                # 抛出报错前打印jstack
                node = get_node("dble-1")
                print_jstack(node)
                logger.debug(f"print dble jstack end")

                raise e
            else:
                sleep_by_time(context, sep_time)
                # time.sleep(sep_time)

    assert str(output).find(text_info) > -1, "expect output: {0} in {1}, but was: {2}".format(context.text, result, output)


@Given('check sql thread output in "{result}" by retry "{retry_param}" times and check sleep time use "{sleep_end_key}"')
def step_impl(context, result, retry_param=1, sleep_end_key=None):
    check_sql_thread(context, result, retry_param)

    # 获取到结果集之后判断sleep的时间是否过长或过短，过长或过短skip当前scenario
    if sleep_end_key is not None:
        sleep_end_time = getattr(context, sleep_end_key)
        logger.debug(f"sleep end time: {sleep_end_time}, current time: {time.time()}")
        if sleep_end_time is not None:
            if time.time() < sleep_end_time-2 or time.time() > sleep_end_time+2:
                logger.debug("sleep time too short or too long, skip case")
                context.scenario.skip(f"sleep time {sleep_end_time} too short or too long, skip case")


@Then('from btrace sleep "{sleep_time}" seconds get sleep end time and save resultset in "{result}"')
def step_impl(context, sleep_time, result=None):
    current_time = time.time()
    end_time = current_time + float(sleep_time)
    if result is not None:
        setattr(context, result, end_time)
        context.logger.debug("the sleep end resultset {0} is {1}".format(result, getattr(context, result)))
