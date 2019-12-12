# -*- coding: utf-8 -*-
# @Time    : 2019/12/11 PM2:40
# @Author  : zhaohongjie@actionsky.com
# **********************
# steps about dble's config change
# **********************
from lxml import etree as ET
from behave import *

from lib.Node import get_ssh
from lib.XMLUtil import get_node_by_keyvalue

@Then('check exist xml node "{node}" in "{target_file}" in host "{host_name}"')
def step_impl(context, node, target_file,host_name):
    sshClient = get_ssh(context.dbles,host_name)
    cmd = "cat {0}".format(target_file)
    rc, sto, ste = sshClient.exec_command(cmd)

    nodeXml = eval(node)

    tree = ET.fromstring(sto)

    tag = nodeXml.get("tag")
    targetNodes = tree.findall(tag)
    targetNodes_filtered= get_node_by_keyvalue(targetNodes, nodeXml.get("kv_map"))
    assert len(targetNodes_filtered)>0, "can't find {0} in xml {1}".format(node, target_file)

