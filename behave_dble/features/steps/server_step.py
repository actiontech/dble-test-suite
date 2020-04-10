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
    node_vars = re.findall(r'\{(.*?)\}', linux_cmd, re.I)
    logger.debug("debug node attr vars: {}".format(node_vars))
    for var in node_vars:
        linux_cmd = linux_cmd.replace("{" + var + "}", getattr(node, var))

    # replace all vars in linux_cmd with corresponding context attribute value, context attr var in %% mode
    context_vars = re.findall(r'%(.*?)%', linux_cmd, re.I)
    logger.debug("debug context attr vars: {}".format(vars))
    for var in context_vars:
        linux_cmd = linux_cmd.replace("%" + var + "%", getattr(context, var))

    rc, sto, ste = node.ssh_conn.exec_command(linux_cmd)

    assert len(ste) == 0, "execute linux cmd {} failed for {}".format(linux_cmd, ste)

    if result_var:
        sto_list = sto.split("\n")
        setattr(context, result_var, sto_list)