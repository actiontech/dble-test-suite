# -*- coding: utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2018/5/18 PM4:58
# @Author  : zhaohongjie@actionsky.com

import re
import time

from behave import *
from hamcrest import *

from . lib.Node import get_node, get_ssh
from . step_function import update_file_content


@Given('restart mysql "{key}" with options "{options}" and reconnect success')
def step_impl(context,key, options):
    context.execute_steps(u'Given restart mysql in "{0}" with options "{1}"'.format(key, options))
    context.execute_steps(u'''
        Given execute admin command
            |cmd                                         | expect |group | index|
            |uproxy update_conns 'uproxy' masters 'host' | success|group1| 0    |
            |uproxy update_conns 'uproxy' slaves  'host' | success|group1| 0 1  |
        ''')
    context.execute_steps(u'Given connect after restart success')

@Given('restart mysql in "{host}" with options')
def restart_mysql(context, host):
    stop_mysql(context, host)

    time.sleep(10)

    update_file_content(context, "/etc/my.cnf", host)

    start_mysql(context, host)
    
@Given('restart mysql in "{host}"')
def restart_mysql(context, host):
    stop_mysql(context, host)

    time.sleep(10)

    start_mysql(context, host)
    
@Given('stop mysql in host "{hostName}"')
def stop_mysql(context, hostName):
    mysql_path = "{0}/support-files/mysql.server".format(context.cfg_mysql['install_path'])

    cmd_status = "{0} status".format(mysql_path)
    cmd_stop = "{0} stop".format(mysql_path)

    ssh = get_ssh(context.mysqls, hostName)
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
    mysql_path = "{0}/support-files/mysql.server".format(context.cfg_mysql['install_path'])

    cmd_start = "{0} start".format(mysql_path)
    node = get_node(context.mysqls, host)
    ssh = node.ssh_conn
    cd,out,err = ssh.exec_command(cmd_start)
    ssh.close()
    node.ssh_conn = None
    success_p = "Starting MySQL.*?SUCCESS"
    obj = re.search(success_p, out)
    isSuccess = obj is not None
    assert isSuccess, "start mysql in host:{0} err: {1}".format(host, err)
    

@Given('connect after restart success')
def step_impl(context):
    cgroup = getattr(context, context.cgroup)
    u_ip = context.uproxy.ip
    u_user = cgroup.user
    u_passwd = cgroup.passwd
    u_port = context.uproxy.port

    connect_test(context, u_ip, u_user, u_passwd, u_port)
    connect_test(context, context.mysql.ip, context.mysql.user, context.mysql.passwd, context.mysql.port)

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

        time.sleep(60)

    assert_that(isSuccess, "can not connect to {0} after 5 minutes wait".format(ip))
