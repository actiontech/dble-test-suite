# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午12:55
# @Author  : irene-coming
import logging
import datetime
import MySQLdb

from steps.connector import Connector
from steps.MySQLObject import MySQLObject

logger = logging.getLogger('root')


class DbleObject(MySQLObject):
    dble_long_live_conns = {}

    def __init__(self, dble_meta):
        self._dble_meta = dble_meta

    def do_execute_query(self, query_meta):
        conn = DbleObject.dble_long_live_conns.get(query_meta.conn_id,None)
        if conn:
            logger.debug("find a exist conn of dble '{0}' to execute query".format(query_meta.conn_id))
        else:
            logger.debug("Can't find a exist dble conn '{0}', try to create a new conn".format(query_meta.conn_id))
            try:
                conn = Connector(host=query_meta.ip, user=query_meta.user, passwd=query_meta.passwd, db=query_meta.db, port=query_meta.port, autocommit=True, charset=query_meta.charset)
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
            DbleObject.dble_long_live_conns.update({query_meta.conn_id:conn})
        else:
            DbleObject.dble_long_live_conns.pop(query_meta.conn_id, None)
            conn.close()

        return res, err, time_cost
