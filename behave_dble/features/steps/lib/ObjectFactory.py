# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM3:48
# @Author  : irene-coming
import logging


from DbleObject import DbleObject
from MySQLObject import MySQLObject
from utils import get_node
logger = logging.getLogger('lib')

class ObjectFactory(object):
    @classmethod
    def create_mysql_object(self, id):
        mysql_meta = get_node(id)
        return MySQLObject(mysql_meta)

    @classmethod
    def create_dble_object(self,id):
        dble_meta = get_node(id)
        return DbleObject(dble_meta)

