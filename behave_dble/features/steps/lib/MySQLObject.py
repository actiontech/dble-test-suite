# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/25 AM11:12
# @Author  : irene-coming
import logging

import MySQLdb
import re

import time

from .utils import update_file_with_sed

logger = logging.getLogger('MySQLObject')


class MySQLObject(object):
    def __init__(self, mysql_meta):
        self._mysql_meta = mysql_meta

    def update_config_with_sedStr_and_restart(self):
        # update_config_with_sedStr_and_restart_mysql(context,self._name, sedStr)
        pass

    def create_conn(self):
        try:
            conn = MySQLdb.connect(self._mysql_meta.ip, self._mysql_meta.mysql_user, self._mysql_meta.mysql_password, '', self._mysql_meta.mysql_port, autocommit = True)
        except MySQLdb.Error, e:
            assert False, "create connection failed for: {}".format(e.args)
        return conn

    def killConnByQuery(self, query):
        conn = self.create_conn()
        cur = conn.cursor()
        cur.execute("show processlist")
        res = cur.fetchall()

        for row in res:
            command_col = row[4]
            if re.search(query, command_col, re.I):
                id_to_kill= row[0]
                break;

        assert id_to_kill, "Can not find the query '{0}' to kill by show processlist, which resultset is {1}".format(query, res)

        cur.execute("kill {0}".format(id_to_kill))

        cur.close()
        conn.close()

    def restart(self, sed_str=None):
        self.stop()

        # to wait stop finished
        time.sleep(10)

        if sed_str:
            update_file_with_sed(sed_str, "/etc/my.cnf", self._mysql_meta)

        self.start()

    def stop(self):
        cmd_status = "{0} status".format(self._mysql_meta.mysql_init_shell)
        cmd_stop = "{0} stop".format(self._mysql_meta.mysql_init_shell)

        ssh = self._mysql_meta.ssh_conn
        rc, status_out, std_err = ssh.exec_command(cmd_status)

        # if mysqld already stopped,do not stop it again
        if status_out.find("MySQL running") != -1:
            stop_cd, stop_out, stop_err = ssh.exec_command(cmd_stop)
            success_p = "Shutting down MySQL.*?SUCCESS"
            obj = re.search(success_p, stop_out)
            isSuccess = obj is not None
            assert isSuccess, "stop mysql in host:{0} err:{1}".format(hostName, stop_err)

        self._mysql_meta.close_ssh()

    def start(self):
        cmd_start = "{0} start".format(self._mysql_meta.mysql_init_shell)

        ssh = self._mysql_meta.ssh_conn
        cd, out, err = ssh.exec_command(cmd_start)
        self._mysql_meta.close_ssh()

        success_p = "Starting MySQL.*?SUCCESS"
        obj = re.search(success_p, out)
        isSuccess = obj is not None
        assert isSuccess, "start mysql in host:{0} err: {1}".format(host, err)

        self.connect_test()

    def connect_test(self):
        conn = None
        isSuccess = False
        max_try = 5
        while conn is None:
            try:
                conn = MySQLdb(self._mysql_meta.ip, self._mysql_meta.mysql_user, self._mysql_meta.mysql_password, '', self._mysql_meta.mysql_port,autocommit=True)
            except MySQLdb.Error, e:
                logger.debug("connect to '{0}' failed for:{1}".format(self._mysql_meta.ip, e))
                conn = None
            finally:
                max_try -= 1
                if max_try == 0 and conn is None: break
                if conn is not None:
                    isSuccess = True
                    conn.close()

            time.sleep(5)

        assert isSuccess, "can not connect to {0} after 25s wait".format(self.ip)