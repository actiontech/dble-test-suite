# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/10 PM5:25
# @Author  : irene-coming
import logging
import re
from behave import *

from steps.lib.utils import get_node

logger = logging.getLogger('steps.server_steps')


@Given('execute linux command in "{host_name}"')
@Given('execute linux command in "{host_name}" and save result in "{result_var}"')
def step_impl(context, host_name, result_var=None):
    linux_cmd = context.text
    assert linux_cmd, "expect linux command not null,but it is"

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

    rc, sto, ste = node.ssh_conn.exec_command(linux_cmd)

    assert len(ste) == 0, "execute linux cmd {} failed for {}".format(linux_cmd, ste)

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


