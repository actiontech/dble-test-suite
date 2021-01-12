# -*- coding: utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/12/3
# @Author  : wangjuan
import logging
import re

from behave import Then, Given
from steps.mysql_steps import execute_sql_in_host

logger = logging.getLogger('steps.step_parameter')

@Then('execute the sql in "{host_name}" in "{mode_name}" mode by parameter from resultset "{rs_name}"')
@Given('execute the sql in "{host_name}" in "{mode_name}" mode by parameter from resultset "{rs_name}"')
@Given('execute the sql in "{host_name}" in "{mode_name}" mode by parameter from resultset "{rs_name}" and save resultset in "{result_key}"')
@Then('execute the sql in "{host_name}" in "{mode_name}" mode by parameter from resultset "{rs_name}" and save resultset in "{result_key}"')
def step_impl(context, host_name, mode_name,rs_name, result_key=None):
    param_value = getattr(context, rs_name)
    assert param_value, "expect parameter not found in {0}".format(rs_name)

    context.logger.debug("the parameter value is {0} ".format(param_value))

    info_dict = context.table[0].as_dict()
    info_dict['sql'] = info_dict['sql'].format(param_value)
    context.logger.debug("the sql value is {0} ".format(info_dict['sql']))

    if info_dict.has_key('expect'):
        expect = info_dict['expect']
        length_obj = re.search(r"length\{(.*?)\}", expect, re.I)
        context.logger.debug("the length_obj value is {0} ".format(length_obj))
        if not length_obj :
            info_dict['expect'] = expect.format(param_value)
            context.logger.debug("the expect value is {0} ".format(info_dict['expect']))

    res, _ = execute_sql_in_host(host_name, info_dict, mode_name)

    if result_key is not None:
        setattr(context, result_key, res)
        context.logger.debug("the resultset {0}] is {1}".format(result_key, getattr(context, result_key)))
