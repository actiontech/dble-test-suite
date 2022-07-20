# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午12:55
# @Author  : irene-coming
import logging

from steps.lib.MySQLObject import MySQLObject

logger = logging.getLogger('DbleObject')


class DbleObject(MySQLObject):
    def __init__(self, dble_meta):
        self._dble_meta = dble_meta

