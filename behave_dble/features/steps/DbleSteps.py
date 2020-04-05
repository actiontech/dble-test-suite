# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午12:58
# @Author  : irene-coming
from .lib import ObjectFactory


@When('execute sql in "{host_name}" in "{mode_name}" mode')
@Given('execute sql in "{host_name}" in "{mode_name}" mode')
@Then('execute sql in "{host_name}" in "{mode_name}" mode')
def execute_sql_in_host(context,host_name, mode_name):
    dble = ObjectFactory.create_dble_object(host_name)
    dble.execute_queries_in_behave_table(context.table, mode_name)