# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM3:48
# @Author  : irene-coming
from .MySQLObject import MySQLObject
from .utils import get_node


def createMySQLObject(context, id):
    raw_mysql_meta = get_node(context.mysqls, id)
    return MySQLObject(raw_mysql_meta)

