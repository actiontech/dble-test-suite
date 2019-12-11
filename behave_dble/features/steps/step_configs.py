# -*- coding: utf-8 -*-
# @Time    : 2019/12/11 PM2:40
# @Author  : zhaohongjie@actionsky.com
# **********************
# steps about dble's config change
# **********************
from lxml import etree as ET
from behave import *
import lib.XMLUtil
from step_reload import get_abs_path


@Then('check exist xml node "{node}" in "{targetXml}"')
def step_impl(context, node, targetXml):
    fullpath = get_abs_path(context, targetXml)

    ET.register_namespace("dble", "http://dble.cloud/")
    tree = ET.parse(fullpath)

    root = tree.getroot()
    targetNodes = root.findAll(node.get("tag"))
    targetNodes_filtered= lib.XMLUtil.get_node_by_keyvalue(targetNodes, node.get("kv"))
    assert len(targetNodes_filtered)>0, "can't find {0} in xml {1}".format(node, targetXml)

