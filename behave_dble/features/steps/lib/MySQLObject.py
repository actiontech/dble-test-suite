# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/25 AM11:12
# @Author  : irene-coming
import logging

import MySQLdb
import re


logger = logging.getLogger('MySQLObject')


class MySQLObject(object):
    def __init__(self, mysql_meta):
        self.super()
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

