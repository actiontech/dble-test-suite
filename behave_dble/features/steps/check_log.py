# -*- coding: utf-8 -*-
# @Time    : 2019/1/3 PM2:12
# @Author  : zhaohongjie@actionsky.com
import re

from behave import *
from hamcrest import *

from features.steps.lib.Node import get_ssh


@Then('check "{logfile}" in "{hostname}" has the warnings')
def step_impl(context,hostname, logfile):
    rs = context.table

    logpath = "{0}/dble/logs/{1}".format(context.cfg_dble['install_dir'], logfile)
    cmd = "cat {0}".format(logpath)
    ssh_client = get_ssh(context.dbles, hostname)
    rc, sto, ste = ssh_client.exec_command(cmd)
    assert len(ste)==0, "cut dble.log failed for: {0}".format(ste[0:200])

    context.logger.debug("show warn content")
    for row in rs:
        level = row[1] # 1 is level
        detail = row[2] # 2 is detail
        if level == "WARNING":
            detail = detail.replace("[", "\[")
            detail = detail.replace("]", "\]")
            str_to_find = "WARN \[WrapperSimpleAppMain\].*{0}".format(detail)
            found_in_log = re.search(str_to_find, sto, flags=re.IGNORECASE) is not None
            assert found_in_log, "warning {0} not found in log".format(row)
            context.logger.debug("warning is found in log:{0}".format(row))
        else:
            context.logger.debug("row:{0}, is not warning, not search".format(row))

