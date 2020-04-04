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
            assert isSuccess, "stop mysql err:{1}".format(stop_err)

        self._mysql_meta.close_ssh()

    def start(self):
        cmd_start = "{0} start".format(self._mysql_meta.mysql_init_shell)

        ssh = self._mysql_meta.ssh_conn
        cd, out, err = ssh.exec_command(cmd_start)
        self._mysql_meta.close_ssh()

        success_p = "Starting MySQL.*?SUCCESS"
        obj = re.search(success_p, out)
        isSuccess = obj is not None
        assert isSuccess, "start mysql err: {1}".format(err)

        self.connect_test()

    def connect_test(self):
        conn = None
        isSuccess = False
        max_try = 5
        while conn is None:
            try:
                conn = MySQLdb.connect(self._mysql_meta.ip, self._mysql_meta.mysql_user, self._mysql_meta.mysql_password, '', self._mysql_meta.mysql_port,autocommit=True)
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

        assert isSuccess, "can not connect to {0} after 25s wait".format(self._mysql_meta.ip)

    def turn_on_general_log(self):
        conn = MySQLdb.connect(self._mysql_meta.ip, self._mysql_meta.mysql_user, self._mysql_meta.mysql_password, '',
                               self._mysql_meta.mysql_port, autocommit=True)

        res, err = conn.query("set global log_output='file'")
        assert err is None, "get general log file fail for {0}".format(err[1])

        res, err = conn.query("set global general_log=off")
        assert err is None, "set general log off fail for {0}".format(err[1])

        res, err = conn.query("show variables like 'general_log_file'")
        assert err is None, "get general log file fail for {0}".format(err[1])

        general_log_file = res[0][1]
        ssh = self._mysql_meta.ssh_conn
        rc, sto, ste = ssh.exec_command('rm -rf {0}'.format(general_log_file))
        assert len(ste) == 0, "rm general_log_file fail for {0}".format(ste)

        res, err = conn.query("set global general_log=on")
        assert err is None, "set general log on fail for {0}".format(err[1])

        conn.close()
        self._mysql_meta.close_ssh()

    def turn_off_general_log(self):
        conn = MySQLdb.connect(self._mysql_meta.ip, self._mysql_meta.mysql_user, self._mysql_meta.mysql_password, '',
                               self._mysql_meta.mysql_port, autocommit=True)

        res, err = conn.query("set global general_log=off")
        assert err is None, "turn off general log fail for {0}".format(err[1])

        conn.close()

    def check_query_in_general_log(self, query, expect_exist, occur_times_expr=None):
        conn = MySQLdb.connect(self._mysql_meta.ip, self._mysql_meta.mysql_user, self._mysql_meta.mysql_password, '',
                               self._mysql_meta.mysql_port, autocommit=True)
        conn.close()

        res, err = conn.query("show variables like 'general_log_file'")
        assert err is None, "get general log file fail for {0}".format(err[1])

        general_log_file = res[0][1]

        find_query_in_genlog_cmd = 'grep -ni "{0}" {1} | wc -l'.format(query, general_log_file)

        ssh = self._mysql_meta.ssh_conn
        rc, sto, ste = ssh.exec_command(find_query_in_genlog_cmd)

        if expect_exist:
            if occur_times_expr is None:
                expect_occur_times_expr = "==1"
            real_occur_times_as_expected = eval("{0}{1}".format(sto, expect_occur_times_expr))
            assert real_occur_times_as_expected, "expect '{0}' occured {1} times in general log, but it occured {2} times".format(
                query, expect_occur_times_expr, sto);

        else:
            assert 0 == int(sto), "expect general log has no {0}, but it occurs {1} times".format(query, sto);

