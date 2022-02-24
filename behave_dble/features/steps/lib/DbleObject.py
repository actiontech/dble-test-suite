# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午12:55
# @Author  : irene-coming
import logging

from .MySQLObject import MySQLObject

logger = logging.getLogger('root')


class DbleObject(MySQLObject):
    def __init__(self, dble_meta):
        self._dble_meta = dble_meta

