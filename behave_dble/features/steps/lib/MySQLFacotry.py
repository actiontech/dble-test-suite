# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM3:48
# @Author  : irene-coming
from behave_dble.features.steps.lib.MySQLObject import MySQLObject
from behave_dble.features.steps.lib.utils import get_node


def createMySQLObject(context, id):
    # context.
    # MySQLObject()
    raw_mysql_meta = get_mysql_config(context, id)

    return MySQLObject(raw_mysql_meta)

def get_mysql_meta(context, id):


def get_mysql_config(context, id):
    for k, v in context.cfg_mysql.iteritems():
        for ck, cv in context.cfg_mysql[k].iteritems():
            if (cv["ip"] == id) or (cv["hostname"] == id):
                return cv
