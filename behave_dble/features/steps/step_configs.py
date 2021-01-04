# -*- coding: utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2019/12/11 PM2:40
# @Author  : zhaohongjie@actionsky.com
# **********************
# steps about dble's config change
# **********************
from lxml import etree as ET
from behave import *

from lib.utils import get_node,get_ssh
from step_reload import get_abs_path
from lib.XMLUtil import get_node_by_keyvalue


@Then('check exist xml node "{node}" in "{target_file}" in host "{host_name}"')
def step_impl(context, node, target_file,host_name):
    sshClient = get_ssh(host_name)
    cmd = "cat {0}".format(target_file)
    rc, sto, ste = sshClient.exec_command(cmd)
    tree = ET.fromstring(sto)

    nodeXml = eval(node)

    tag = nodeXml.get("tag")
    targetNodes = tree.findall(tag)
    targetNodes_filtered= get_node_by_keyvalue(targetNodes, nodeXml.get("kv_map"))
    assert len(targetNodes_filtered)>0, "can't find {0} in xml {1}".format(node, target_file)

@Given('update "{target_file}" from "{host_name}"')
def step_impl(context, host_name, target_file):
    """
    dble config files is change, but config file in behave is not, then scp the changed files out first, then apply user's config change, last, put it back
    :param context:
    :param host_name:
    :param target_file: fullpath file
    :return:
    """
    node = get_node("dble-1")
    local_file = get_abs_path(context, target_file)

    source_remote_file = "{0}/dble/conf/{1}".format(node.install_dir, target_file)
    node.sftp_conn.sftp_get(source_remote_file, local_file)