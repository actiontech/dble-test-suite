# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午12:55
# @Author  : irene-coming
import logging

from .QueryMeta import QueryMeta
from .MySQLObject import MySQLObject

logger = logging.getLogger('DbleObject')


class DbleObject(MySQLObject):
    def __init__(self, dble_meta):
        self._dble_meta = dble_meta

    def execute_queries_in_behave_table(self, table, mode_name):

        for row in table:
            self.exec_query_with_dict(row.as_dict(), mode_name)

    def exec_query_with_dict(self, info_dic, mode_name):
        query_meta = QueryMeta(info_dic, mode_name, self._mysql_meta)
        self.do_execute_query(query_meta)

