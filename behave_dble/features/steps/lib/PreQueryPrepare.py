# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午3:54
# @Author  : irene-coming
import re
from ObjectFactory import ObjectFactory

class PreQueryPrepare(object):
    def __init__(self, query_meta):
        self._expect = query_meta.expect

    def prepare(self):
        need_check_sharding = re.search(r'dest_node:(.*)', self._expect, re.I)
        if need_check_sharding:
            shardings_host = need_check_sharding.group(1)
            mysql = ObjectFactory.create_mysql_object(shardings_host)
            mysql.turn_on_general_log()