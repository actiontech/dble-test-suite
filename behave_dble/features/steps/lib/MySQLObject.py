# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/25 AM11:12
# @Author  : irene-coming
import datetime
import logging

import MySQLdb
import re

import time

from steps.lib.ConnUtil import MysqlConnUtil
from steps.lib.utils import update_file_with_sed

logger = logging.getLogger('lib.MySQLObject')


class MySQLObject(object):
    # store long live conns in dictionary, key is conn id ,value is conn object
    long_live_conns = {}

    def __init__(self, mysql_meta):
        self._mysql_meta = mysql_meta

    def create_conn(self):
        try:
            conn = MySQLdb.connect(self._mysql_meta.ip, self._mysql_meta.mysql_user, self._mysql_meta.mysql_password, '', self._mysql_meta.mysql_port, autocommit = True)
        except MySQLdb.Error, e:
            assert False, "create connection failed for: {}".format(e.args)
        return conn

    def restart(self, sed_str=None):
        self.stop()

        # to wait stop finished
        time.sleep(10)

        self.start(sed_str)

    def stop(self):
        cmd_status = "{0} status".format(self._mysql_meta.mysql_init_shell)
        cmd_stop = "{0} stop".format(self._mysql_meta.mysql_init_shell)

        rc, status_out, std_err = self._mysql_meta.ssh_conn.exec_command(cmd_status)

        # if mysqld already stopped,do not stop it again
        if status_out.find("MySQL running") != -1:
            # self.turn_off_general_log_and_clean()

            logger.debug("try to stop mysql")

            stop_cd, stop_out, stop_err = self._mysql_meta.ssh_conn.exec_command(cmd_stop)
            success_p = "Shutting down MySQL.*?SUCCESS"
            obj = re.search(success_p, stop_out)
            isSuccess = obj is not None
            assert isSuccess, "stop mysql err:{}".format(stop_err)

        self._mysql_meta.close_ssh()

    def start(self, sed_str=None):
        if sed_str:
            self.update_config(sed_str)

        cmd_start = "{0} start".format(self._mysql_meta.mysql_init_shell)

        ssh = self._mysql_meta.ssh_conn
        cd, out, err = ssh.exec_command(cmd_start)
        self._mysql_meta.close_ssh()
        logger.debug("check mysql start success")
        success_p = "Starting MySQL.*?SUCCESS"
        obj = re.search(success_p, out)
        isSuccess = obj is not None
        assert isSuccess, "start mysql err: {1}".format(err)

        logger.debug("start mysql connect_test")
        self.connect_test()

    def update_config(self, sed_str):
        update_file_with_sed(sed_str, "/etc/my.cnf", self._mysql_meta)

    def connect_test(self):
        conn = None
        isSuccess = False
        max_try = 5
        while conn is None:
            try:
                conn = MysqlConnUtil(host=self._mysql_meta.ip, user=self._mysql_meta.mysql_user,
                                     passwd=self._mysql_meta.mysql_password, db='',
                                     port=self._mysql_meta.mysql_port, autocommit=True)
            except MySQLdb.Error, e:
                logger.debug("connect to '{0}' failed for:{1}".format(self._mysql_meta.ip, e))
                conn = None
            finally:
                max_try -= 1
                if max_try == 0 and conn is None: break
                if conn is not None:
                    isSuccess = True
                    conn.close()

            time.sleep(2)

        assert isSuccess, "can not connect to {0} after 25s wait".format(self._mysql_meta.ip)

    def turn_on_general_log(self, to_clean_old_file=True):
        if to_clean_old_file:
            self.turn_off_general_log_and_clean()

        conn = MysqlConnUtil(host=self._mysql_meta.ip, user=self._mysql_meta.mysql_user, passwd=self._mysql_meta.mysql_password, db='',
                             port=self._mysql_meta.mysql_port, autocommit=True)

        res, err = conn.execute("set global general_log=on")
        assert err is None, "set general log on fail for {0}".format(err[1])

        conn.close()

    def turn_off_general_log(self):
        conn = MysqlConnUtil(host=self._mysql_meta.ip, user=self._mysql_meta.mysql_user, passwd=self._mysql_meta.mysql_password, db='',
                             port=self._mysql_meta.mysql_port, autocommit=True)

        res, err = conn.execute("set global general_log=off")
        assert err is None, "turn off general log fail for {0}".format(err[1])

        conn.close()

    def turn_off_general_log_and_clean(self):
        conn = MysqlConnUtil(host=self._mysql_meta.ip, user=self._mysql_meta.mysql_user, passwd=self._mysql_meta.mysql_password, db='',
                             port=self._mysql_meta.mysql_port, autocommit=True)

        res, err = conn.execute("set global log_output='file'")
        assert err is None, "get general log file fail for {0}".format(err[1])

        res, err = conn.execute("set global general_log=off")
        assert err is None, "set general log off fail for {0}".format(err[1])

        res, err = conn.execute("show variables like 'general_log_file'")
        assert err is None, "get general log file fail for {0}".format(err[1])

        general_log_file = res[0][1]
        ssh = self._mysql_meta.ssh_conn
        rc, sto, ste = ssh.exec_command('rm -rf {0}'.format(general_log_file))
        assert len(ste) == 0, "rm general_log_file fail for {0}".format(ste)

        conn.close()
        self._mysql_meta.close_ssh()

    def check_query_in_general_log(self, query, expect_exist, expect_occur_times_expr=None):
        conn = MysqlConnUtil(host=self._mysql_meta.ip, user=self._mysql_meta.mysql_user, passwd=self._mysql_meta.mysql_password, db='',
                             port=self._mysql_meta.mysql_port, autocommit=True)

        res, err = conn.execute("show variables like 'general_log_file'")
        assert err is None, "get general log file fail for {0}".format(err[1])
        conn.close()

        general_log_file = res[0][1]

        find_query_in_genlog_cmd = 'grep -ni "{0}" {1} | wc -l'.format(query, general_log_file)

        ssh = self._mysql_meta.ssh_conn
        rc, sto, ste = ssh.exec_command(find_query_in_genlog_cmd)

        if expect_exist:
            if expect_occur_times_expr is None:
                expect_occur_times_expr = "==1"
            real_occur_times_as_expected = eval("{0}{1}".format(sto, expect_occur_times_expr))
            assert real_occur_times_as_expected, "expect '{0}' occured {1} times in general log, but it occured {2} times".format(
                query, expect_occur_times_expr, sto);

        else:
            assert 0 == int(sto), "expect general log has no {0}, but it occurs {1} times".format(query, sto);

    def do_execute_query(self, query_meta):
        conn = MySQLObject.long_live_conns.get(query_meta.conn_id,None)
        if conn:
            logger.debug("find a exist conn '{0}' to execute query".format(query_meta.conn_id))
        else:
            logger.debug("Can't find a exist conn '{0}', try to create a new conn".format(query_meta.conn_id))
            try:
                conn = MysqlConnUtil(host=query_meta.ip, user=query_meta.user, passwd=query_meta.passwd, db=query_meta.db, port=query_meta.port, autocommit=True, charset=query_meta.charset)
            except MySQLdb.Error, e:
                err = e.args
                return None, err, 0

        assert conn, "expect {0} find or create success, but failed".format(query_meta.conn_id)

        starttime = datetime.datetime.now()
        res, err = conn.execute(query_meta.sql)
        endtime = datetime.datetime.now()

        time_cost = endtime - starttime

        logger.debug("to close {0} {1}".format(query_meta.conn_id, query_meta.bClose))

        if query_meta.bClose.lower() == "false":
            MySQLObject.long_live_conns.update({query_meta.conn_id:conn})
        else:
            MySQLObject.long_live_conns.pop(query_meta.conn_id, None)
            conn.close()

        return res, err, time_cost

    def kill_all_conns(self, exclude_conn_ids=None):
        conn = MysqlConnUtil(host=self._mysql_meta.ip, user=self._mysql_meta.mysql_user, passwd=self._mysql_meta.mysql_password, db='',
                             port=self._mysql_meta.mysql_port, autocommit=True)
        res, err = conn.execute("show processlist")

        for row in res:
            conn_id = row[0]
            not_show_processlist = row[7] != "show processlist"#for excluding show processlist conn itself
            if not_show_processlist and exclude_conn_ids and str(conn_id) not in exclude_conn_ids:
                res, err = conn.execute("kill {}".format(conn_id))
                assert err is None, "kill conn '{}' failed for {}".format(conn_id,err[1])
        logger.debug("kill connections success, excluding connection ids:{}".format(exclude_conn_ids))
        conn.close()

    def kill_conns(self, conn_ids):
        conn = MysqlConnUtil(host=self._mysql_meta.ip, user=self._mysql_meta.mysql_user, passwd=self._mysql_meta.mysql_password, db='',
                             port=self._mysql_meta.mysql_port, autocommit=True)
        res, err = conn.execute("show processlist")

        logger.debug("debug 1: {}".format(conn_ids))
        for row in res:
            conn_id = row[0]
            not_show_processlist = row[7] != "show processlist"#for excluding show processlist conn itself
            if not_show_processlist and str(conn_id) in conn_ids:
                res, err = conn.execute("kill {}".format(conn_id))
                assert err is None, "kill conn '{}' failed for {}".format(conn_id,err[1])
        logger.debug("kill connections success, killed connection ids:{}".format(conn_ids))
        conn.close()
