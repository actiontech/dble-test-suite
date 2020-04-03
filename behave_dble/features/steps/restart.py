# -*- coding: utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2018/5/18 PM4:58
# @Author  : zhaohongjie@actionsky.com

import re
import time
import os
import MySQLdb
from behave import *
from hamcrest import *

from lib.DBUtil import DBUtil
from . lib.utils import get_node, get_ssh
from . step_function import update_file_content, merge_cmd_strings


@Given('restart mysql in "{host}" with sed cmds to update mysql config')
def update_config_and_restart_mysql(context, host):
    restart_mysql(context, host, context.text)

def update_config_with_sedStr_and_restart_mysql(context, host, sedStr=None):
    restart_mysql(context, host, sedStr)

@Given('restart mysql in "{host}"')
def restart_mysql(context, host, sedStr=None):
    stop_mysql(context, host)

    # to wait stop finished
    time.sleep(10)

    if sedStr:
        update_file_content(context, "/etc/my.cnf", host, sedStr)

    start_mysql(context, host)

@Given('stop mysql in host "{hostName}"')
def stop_mysql(context, hostName):
    node = get_node(context.mysqls, hostName)

    mysql_path = "{0}/support-files/mysql.server".format(node.install_path)

    cmd_status = "{0} status".format(mysql_path)
    cmd_stop = "{0} stop".format(mysql_path)

    ssh = node.ssh_conn
    rc, status_out, std_err = ssh.exec_command(cmd_status)

    # if mysqld already stopped,do not stop it again
    if status_out.find("MySQL running") != -1:
        stop_cd, stop_out,stop_err = ssh.exec_command(cmd_stop)
        success_p = "Shutting down MySQL.*?SUCCESS"
        obj = re.search(success_p, stop_out)
        isSuccess = obj is not None
        assert isSuccess, "stop mysql in host:{0} err:{1}".format(hostName, stop_err)
    else:
        context.logger.info("status_re: {0} , over".format(status_out))

@Given('start mysql in host "{host}"')
def start_mysql(context, host):
    node = get_node(context.mysqls, host)

    mysql_path = "{0}/support-files/mysql.server".format(node.install_path)

    cmd_start = "{0} start".format(mysql_path)
    ssh = node.ssh_conn
    cd,out,err = ssh.exec_command(cmd_start)
    ssh.close()
    node.ssh_conn = None
    success_p = "Starting MySQL.*?SUCCESS"
    obj = re.search(success_p, out)
    isSuccess = obj is not None
    assert isSuccess, "start mysql in host:{0} err: {1}".format(host, err)

    node = get_node(context.mysqls, host)
    ip = node.ip
    port = node.mysql_port
    user = node.mysql_user
    passwd = node.mysql_password
    connect_test(context, ip, user, passwd, port)

@Given('connect after restart success')
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

        time.sleep(5)

    assert_that(isSuccess, "can not connect to {0} after 25s wait".format(ip))

@Given('change file "{fileName}" in "{hostname}" locate "{dir}" with sed cmds')
def step_impl(context,fileName,hostname,dir):
    if hostname.startswith('dble'):
        node = get_node(context.dbles, hostname)
        ssh = node.ssh_conn
        targetFile = "{0}/dble/conf/{1}".format(node.install_dir,fileName)
        cmd = merge_cmd_strings(context,context.text,targetFile)
        rc, stdout, stderr = ssh.exec_command(cmd)
    else:
        ssh = get_ssh(context.mysqls, hostname)
        targetFile = "{0}/{1}".format(dir,fileName)
        cmd = merge_cmd_strings(context,context.text,targetFile)
        rc, stdout, stderr = ssh.exec_command(cmd)
    assert_that(len(stderr)==0, 'update file content wtih:{0}, got err:{1}'.format(cmd,stderr))

@Given('change btrace "{btrace}" locate "{dir}" with sed cmds')
def step_impl(context,btrace,dir):
    targetFile = "{0}/{1}".format(dir, btrace)
    cmd = merge_cmd_strings(context, context.text, targetFile)
    status = os.system(cmd)
    assert status == 0, "change {0} failed".format(btrace)
    context.logger.info("change {0} successed".format(btrace))

