# -*- coding: utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2019/1/3 PM2:12
# @Author  : zhaohongjie@actionsky.com
import re
from behave import *

from lib.utils import get_node

@Then('check "{file}" in "{hostname}" was empty')
def step_impl(context,hostname, file):
    node = get_node(hostname)
    path = "{0}".format(file)
    print ("{0}".format(file))
    cmd = "cat {0}".format(path)
    ssh_client = node.ssh_conn
    rc, sto, ste = ssh_client.exec_command(cmd)
    print ("rc:{0}; sto:{1}; ste:{2}\n".format(rc, sto, ste))
    assert len(sto)==0, "cat file is not empty!"
    assert len(ste)==0, "cat file failed for: {0}".format(ste[0:200])


@Then('check "{logfile}" in "{hostname}" has the warnings')
def step_impl(context,hostname, logfile):
    rs = context.table

    node = get_node(hostname)
    logpath = "{0}/dble/logs/{1}".format(node.install_dir, logfile)
    cmd = "cat {0}".format(logpath)
    ssh_client = node.ssh_conn
    rc, sto, ste = ssh_client.exec_command(cmd)
    assert len(ste)==0, "cat dble.log failed for: {0}".format(ste[0:200])

    context.logger.debug("show warn content")
    for row in rs:
        level = row[1] # 1 is level
        detail = row[2] # 2 is detail
        if level == "WARNING":
            # if (detail.rfind('$') != -1):
            #     dble_version = context.cfg_dble['ftp_path'].split('/')[-2]
            #     detail = detail.replace("${version}", dble_version)
            detail = detail.replace("[", "\[")
            detail = detail.replace("]", "\]")
            str_to_find = "WARN \[.*?\].*{0}".format(detail)
            found_in_log = re.search(str_to_find, sto, flags=re.IGNORECASE) is not None
            assert found_in_log, "warning {0} not found in log".format(row)
            context.logger.debug("warning is found in log:{0}".format(row))
        else:
            context.logger.debug("row:{0}, is not warning, not search".format(row))

