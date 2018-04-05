# -*- coding: utf-8 -*-
# @Time    : 2018/3/30 PM5:54
# @Author  : zhaohongjie@actionsky.com

from xml.etree import ElementTree as ET
from lxml import etree as ET
# from xml.etree.ElementTree import ElementTree as ET

def if_match(node, kv_map):
    '''判断某个节点是否包含所有传入参数属性
       node: 节点
       kv_map: 属性及属性值组成的map'''
    for key in kv_map:
        if node.get(key) != kv_map.get(key):
            return False
    return True

def get_node_by_keyvalue(nodelist, kv_map):
    '''根据属性及属性值定位符合的节点，返回节点
       nodelist: 节点列表
       kv_map: 匹配属性及属性值map'''
    result_nodes = []
    for node in nodelist:
        if if_match(node, kv_map):
            result_nodes.append(node)
    return result_nodes


# ---------------change -----
def change_node_properties(nodelist, kv_map, is_delete=False):
    '''修改/增加 /删除 节点的属性及属性值
       nodelist: 节点列表
       kv_map:属性及属性值map'''
    for node in nodelist:
        for key in kv_map:
            if is_delete:
                if key in node.attrib:
                    del node.attrib[key]
            else:
                node.set(key, kv_map.get(key))


def change_node_text(nodelist, text, is_add=False, is_delete=False):
    '''改变/增加/删除一个节点的文本
       nodelist:节点列表
       text : 更新后的文本'''
    for node in nodelist:
        if is_add:
            node.text += text
        elif is_delete:
            node.text = ""
        else:
            node.text = text

def get_xml_from_str(str):
    return ET.fromstring("<tmproot>" + str + "</tmproot>")

def add_child_in_text(file, parentNode, childNodeInText):
    '''file:指定的xml文件的一个节点添加子节点
       parentNodeID: 要添加节点的父节点，格式 {tag:schema,kv_map:{k1:v1,k2:v2}}
       childNodeInText: 子节点'''
    childNodeRoot = get_xml_from_str(childNodeInText)

    add_child_in_xml(file, parentNode, childNodeRoot)

def add_child_in_xml(file, parentNode, childNodeRoot):
    ET.register_namespace("dble", "http://dble.cloud/")
    tree = ET.parse(file)

    if parentNode["tag"].lower() == "root":
        parentNodes = [tree.getroot()]
    else:
        tagNodes = tree.findall(parentNode["tag"])
        parentNodes = get_node_by_keyvalue(tagNodes, parentNode["kv_map"])

    assert len(parentNodes)>0, "cant not find parent tag:{0} in file {1} to insert child node".format(parentNode["tag"], file)

    #add child nodes, delete the same name ones if exists
    for node in parentNodes:
        for child in childNodeRoot:
            del_node_by_name(node, child)
            idx = get_Insert_Idx(node, child)
            node.insert(idx,child)

    doctype=""
    if file.find('rule.xml') > -1:
        doctype='<!DOCTYPE dble:rule SYSTEM "rule.dtd">'
    elif file.find('schema.xml') > -1:
        doctype='<!DOCTYPE dble:schema SYSTEM "schema.dtd">'
    elif file.find('server.xml') > -1:
        doctype='<!DOCTYPE dble:server SYSTEM "server.dtd">'

    xmlstr = ET.tostring(tree, encoding="utf-8", xml_declaration=True, doctype=doctype)
    with open(file, 'wb') as f:
        f.writelines(xmlstr)

def delete_child_node(file, kv_child, kv_parent):
    ET.register_namespace("dble", "http://dble.cloud/")
    tree = ET.parse(file)

    parentTag = kv_parent["tag"].lower()
    if parentTag == "root":
        parentNodes = [tree.getroot()]
    else:
        tagNodes = tree.findall(parentTag)
        parentNodes = get_node_by_keyvalue(tagNodes, kv_parent["kv_map"])

    assert len(parentNodes)>0, "cant not find parent tag:{0} in file {1} to insert child node".format(kv_parent["tag"], file)

    for node in parentNodes:
        children = node.findall(kv_child["tag"])
        for child in children:
            if if_match(child, kv_child["kv_map"]):
                node.remove(child)

    doctype=""
    if file.find('rule.xml') > -1:
        doctype='<!DOCTYPE dble:rule SYSTEM "rule.dtd">'
    elif file.find('schema.xml') > -1:
        doctype='<!DOCTYPE dble:schema SYSTEM "schema.dtd">'
    elif file.find('server.xml') > -1:
        doctype='<!DOCTYPE dble:server SYSTEM "server.dtd">'

    xmlstr = ET.tostring(tree, encoding="utf-8", xml_declaration=True, doctype=doctype)
    with open(file, 'wb') as f:
        f.writelines(xmlstr)


# delete the same name node with the given child
def del_node_by_name(node, child):
    name_to_del = child.get('name')
    nodeChildren = node.findall(child.tag)

    for nchild in nodeChildren:
        if nchild.get('name')==name_to_del:
            node.remove(nchild)

def get_Insert_Idx(node, child):
    existsChildren = node.findall(child.tag)
    idx = 0
    for tagChild in existsChildren:
        tmp = node.index(tagChild)
        if tmp > idx: idx = tmp

    if idx > 0: idx = idx+1
    return idx

if __name__ == "__main__":
    import sys
    command = sys.argv[1]
    if command == "rule":
        seg="""
        <tableRule name="date_rule">
            <rule>
                <columns>id</columns>
                <algorithm>date_func</algorithm>
            </rule>
        </tableRule>
        <function class="Date" name="date_func">
            <property name="dateFormat">yyyy-MM-dd</property>
            <property name="sEndDate">2018-01-31</property>
            <property name="sPartionDay">10</property>
        </function>
        """
        add_child_in_text('dble_conf/conf_template/rule.xml', {"tag": "root", "kv_map":{}}, seg)
    elif command == "schema":
        seg="""
        <table name="date_table" dataNode="dn1,dn2,dn3,dn4" rule="date_rule" />
        """
        add_child_in_text('dble_conf/conf_template/schema.xml', {"tag": "schema", "kv_map":{"name": "mytest"}}, seg)
