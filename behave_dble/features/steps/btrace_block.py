# -*- coding: utf-8 -*-
# @Time    : 2019/6/25 AM10:56
# @Author  : zhaohongjie@actionsky.com
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

from threading import Thread, Condition

import time

from behave import *
from hamcrest import *

from lib.Node import get_sftp, get_ssh

global btrace_threads
btrace_threads=[]

def check_btrace_running(sshClient, btraceScript):
    cmd = "ps -ef |grep -v -w grep| grep -F -c {0}".format(btraceScript)
    rc, sto, ste = sshClient.exec_command(cmd)
    return int(sto)==2
    #sto==2, because btrace ps will show like:
    # root     31010     1  0 Jun26 ?        00:00:00 /bin/sh /opt/btrace/bin/btrace -o /opt/dble/BtraceAddMetaLock.java.log 30919 /opt/dble/BtraceAddMetaLock.java
    # root     31011 31010  0 Jun26 ?        00:00:58 /usr/java/jdk1.8.0_121/bin/java -Dcom.sun.btrace.unsafe=true -cp /opt/btrace/build/btrace-client.jar:/usr/java/jdk1.8.0_121/lib/tools.jar:/usr/share/lib/java/dtrace.jar com.sun.btrace.client.Main -o /opt/dble/BtraceAddMetaLock.java.log 30919 /opt/dble/BtraceAddMetaLock.java

def stop_btrace(sshClient, btraceScript):
    cmd = "kill -SIGINT `jps | grep Main | awk '{{print $1}}'`".format(btraceScript)
    rc, sto, ste = sshClient.exec_command(cmd)
    assert len(ste) == 0, "kill btrace err:{0}".format(ste)
    time.sleep(5)

def run_btrace_script(sshClient, btraceScript):
    getDblePidCmd = "jps | grep WrapperSimpleApp | awk '{print $1}'"
    rc, sto, ste = sshClient.exec_command(getDblePidCmd)
    assert len(sto)>0, "dble pid not found!!!"

    #{0}:btrace file with dir,{1}:btrace file, {2}:dble pid
    cmd = "btrace -o {0}.log {1} {0}".format(btraceScript, sto)
    rc, sto, ste = sshClient.exec_command(cmd, timeout=300)
    assert len(ste)==0,"btrace err:{0}".format(ste)

@Given('prepare a thread run btrace script "{btraceScript}" in "{host}"')
def step_impl(context, btraceScript, host):
    sshClient = get_ssh(context.dbles, host)

    isBtraceRunning = check_btrace_running(sshClient,btraceScript)
    context.logger.info("isBtraceRunning:{0} before try to run {1}".format(isBtraceRunning, btraceScript))
    if not isBtraceRunning:
        sftpClient = get_sftp(context.dbles, host)
        localFile = "assets/{0}".format(btraceScript)
        remoteFile = "{0}/dble/{1}".format(context.cfg_dble['install_dir'],btraceScript)
        sftpClient.sftp_put(localFile, remoteFile)

        global btrace_threads
        thd = Thread(target=run_btrace_script, args=(sshClient, remoteFile),name=btraceScript)
        btrace_threads.append(thd)

        thd.setDaemon(True)
        thd.start()
        # run_btrace_script(sshClient, remoteFile)

def run_mysql_query(sshClient, context):
    context.logger.debug("btrace is running, start query!!!")
    time.sleep(5)
    for row in context.table:
        user = row["user"]
        passwd = row["passwd"]
        sql = row["sql"]
        db = row["db"]
        if db is None: db = ''

        cmd = u"nohup {0}/bin/mysql -u{1} -p{2} -P{3} -c -D{4} -e'{5}' >/tmp/dble_query.log 2>&1 &".format(context.cfg_mysql['install_path'], user, passwd,context.cfg_dble['client_port'], db, sql)
        rc, sto, ste = sshClient.exec_command(cmd)
        assert len(ste)==0, "impossible err occur"

@Given('execute sqls in "{host}" at background')
def step_impl(context, host):
    sshClient = get_ssh(context.dbles, host)

    run_mysql_query(sshClient, context)

def check_btrace_output(sshClient, btraceScript, expectTxt, context):
    retry=0
    isFound = False
    while retry<5:
        time.sleep(2) # a interval wait for query run into
        cmd = "cat {0}.log | grep '{1}' -c".format(btraceScript, expectTxt)
        rc, sto, ste = sshClient.exec_command(cmd)
        assert len(ste)==0, "btrace err:{0}".format(ste)
        isFound = int(sto)==1
        if isFound:
            context.logger.debug("query blocked by btrace is found in {0}s".format((retry+1)*2))
            break

        retry=retry+1

    assert isFound, "can not find expect text '{0}' in {1}.log".format(expectTxt, btraceScript)

@Then('check btrace "{btraceScript}" output in "{host}"')
def step_impl(context, btraceScript, host):
    sshClient = get_ssh(context.dbles, host)

    remoteFile = "{0}/dble/{1}".format(context.cfg_dble['install_dir'],btraceScript)
    check_btrace_output(sshClient, remoteFile, context.text, context)

def kill_query(sshClient,query, context):
    cmd = u"kill -9 `ps -ef | grep -F '{0}'| grep -v grep | awk '{{print $2}}'`".format(query)
    rc, sto, ste = sshClient.exec_command(cmd)
    assert len(ste)==0, "kill query client failed for: {0}".format(ste)

@Given('kill mysql query in "{host}" forcely')
def step_impl(context, host):
    sshClient = get_ssh(context.dbles, host)

    kill_query(sshClient, context.text, context)

@Given('stop btrace script "{btraceScript}" in "{host}"')
def step_impl(context,btraceScript,host):
    sshClient = get_ssh(context.dbles, host)

    isBtraceRunning = check_btrace_running(sshClient,btraceScript)
    context.logger.info("isBtraceRunning:{0} before try to stop {1}".format(isBtraceRunning,btraceScript))
    if isBtraceRunning:
        stop_btrace(sshClient, btraceScript)

@Given('destroy btrace threads list')
def destroy_threads(context):
    global btrace_threads
    for thd in btrace_threads:
        context.logger.debug("join btrace thread:".format(thd.name))
        thd.join()