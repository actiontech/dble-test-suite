# -*- coding: utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2018/5/18 PM4:58
# @Author  : zhaohongjie@actionsky.com

import os
from behave import *
from hamcrest import *

from . lib.utils import get_node, get_ssh, merge_cmd_strings

@Given('change file "{fileName}" in "{hostname}" locate "{dir}" with sed cmds')
def step_impl(context,fileName,hostname,dir):
    if hostname.startswith('dble'):
        node = get_node(context.dbles, hostname)
        ssh = node.ssh_conn
        targetFile = "{0}/dble/conf/{1}".format(node.install_dir,fileName)
        cmd = merge_cmd_strings(context.text,targetFile)
        rc, stdout, stderr = ssh.exec_command(cmd)
    else:
        ssh = get_ssh(context.mysqls, hostname)
        targetFile = "{0}/{1}".format(dir,fileName)
        cmd = merge_cmd_strings(context.text,targetFile)
        rc, stdout, stderr = ssh.exec_command(cmd)
    assert_that(len(stderr)==0, 'update file content wtih:{0}, got err:{1}'.format(cmd,stderr))

@Given('change btrace "{btrace}" locate "{dir}" with sed cmds')
def step_impl(context,btrace,dir):
    targetFile = "{0}/{1}".format(dir, btrace)
    cmd = merge_cmd_strings(context.text, targetFile)
    status = os.system(cmd)
    assert status == 0, "change {0} failed".format(btrace)
    context.logger.info("change {0} successed".format(btrace))

