# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2023/8/3
# @Author  : wujinling

import logging
import datetime
import MySQLdb

from steps.lib.ConnUtil import MysqlConnUtil
from steps.lib.MySQLObject import MySQLObject

logger = logging.getLogger('root')


class ClickhouseObject(MySQLObject):
    clickhouse_long_live_conns = {}

    def __init__(self, clickhouse_meta):
        self._clickhouse_meta = clickhouse_meta

    def do_execute_query(self, query_meta):
        conn = ClickhouseObject.clickhouse_long_live_conns.get(query_meta.conn_id,None)
        if conn:
            logger.debug("find a exist conn of clickhouse '{0}' to execute query".format(query_meta.conn_id))
        else:
            logger.debug("Can't find a exist clickhouse conn '{0}', try to create a new conn".format(query_meta.conn_id))
            try:
                conn = MysqlConnUtil(host=query_meta.ip, user=query_meta.user, passwd=query_meta.passwd, db=query_meta.db, port=query_meta.port, autocommit=True, charset=query_meta.charset)
            except MySQLdb.Error as e:
                err = e.args
                return None, err, 0

        assert conn, "expect {0} find or create success, but failed".format(query_meta.conn_id)

        starttime = datetime.datetime.now()
        res, err = conn.execute(query_meta.sql)
        endtime = datetime.datetime.now()

        time_cost = endtime - starttime

        logger.debug("to close {0} {1}".format(query_meta.conn_id, query_meta.bClose))

        if query_meta.bClose.lower() == "false":
            ClickhouseObject.clickhouse_long_live_conns.update({query_meta.conn_id:conn})
        else:
            ClickhouseObject.clickhouse_long_live_conns.pop(query_meta.conn_id, None)
            conn.close()

        return res, err, time_cost
