# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/25 AM11:12
# @Author  : irene-coming

class MySQLObject(object):
    def __init__(self,name):
        self._name=name

    def update_config_with_sedStr_and_restart(self):
        update_config_with_sedStr_and_restart_mysql(context,self._name, sedStr)