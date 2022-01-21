# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/10 PM5:25
# @Author  : irene-coming
import logging
import os
import re
from behave import *
from hamcrest import *

from steps.lib.utils import get_node

logger = logging.getLogger('root')


@Given('execute linux command in "{host_name}"')
@Given('execute linux command in "{host_name}" and save result in "{result_var}"')
@Given('execute linux command in "{host_name}" and contains exception "{exception_var}"')
def step_impl(context, host_name, result_var=None, exception_var=None):
    linux_cmd = context.text
    assert linux_cmd, "expect linux command not null,but it is"

    if host_name == "behave":
        node = None
    else:
        node = get_node(host_name)
    # replace all vars in linux_cmd with corresponding node attribute value, node attr var in {} mode
    node_vars = re.findall(r'\{node:(.*?)\}', linux_cmd, re.I)
    logger.debug("debug node attr vars: {}".format(node_vars))
    for var in node_vars:
        linux_cmd = linux_cmd.replace("{node:" + var + "}", str(getattr(node, var)))

    # replace all vars in linux_cmd with corresponding context attribute value, context attr var in %% mode
    context_vars = re.findall(r'\{context:(.*?)\}', linux_cmd, re.I)
    logger.debug("debug context attr vars: {}".format(context_vars))
    for var in context_vars:
        linux_cmd = linux_cmd.replace("{context:" + var + "}", getattr(context, var))

    if node:
        rc, sto, ste = node.ssh_conn.exec_command(linux_cmd)
        if exception_var:
            assert_that(str(ste), contains_string(str(exception_var)), "expect execute linux cmd {} failed for {}, real err: {}".format(linux_cmd, exception_var, ste))
        else:
            assert len(ste) == 0, "execute linux cmd {} failed for {}".format(linux_cmd, ste)
    else:
        status = os.system(linux_cmd)
        assert status == 0, "cmd {} failed".format(linux_cmd)
    if result_var:
        sto_list = sto.splitlines()
        setattr(context, result_var, sto_list)

@Given('merge resultset of "{var1}" and "{var2}" into "{new_var}"')
def step_impl(context, var1, var2, new_var):
    var1_value = getattr(context, var1, None)
    var2_value = getattr(context, var2, None)
    if var1_value is None:
        new_value = var2_value
    elif var2_value is None:
        new_value = var1_value
    else:
        new_value = var1_value + var2_value

    setattr(context, new_var, new_value)


