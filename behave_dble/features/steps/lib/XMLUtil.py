# -*- coding: utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2018/3/30 PM5:54
# @Author  : zhaohongjie@actionsky.com

# from xml.etree import ElementTree as ET
from lxml import etree as ET


def if_match(node, kv_map):
    '''判断某个节点是否包含所有传入参数属性
       node: 节点
       kv_map: 属性及属性值组成的map'''
    if kv_map:
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


def get_node_attr_by_kv(parentNode, childNode, file):
    tree = ET.parse(file)
    parentNodes = get_parent_nodes_from_dic(tree, parentNode)
    childTag = childNode.get("tag")
    childAttr = childNode.get("attr")

    targets = None
    for node in parentNodes:
        children = node.findall(childTag)
        targets = get_node_by_keyvalue(children, childNode.get("kv_map"))
        if len(targets) == 1: break

    assert targets, "get node attribute fail, no targets node found"

    target = targets[0]
    dic = {}
    if isinstance(childAttr, list):  # get multi-attr
        for attr in childAttr:
            dic[attr] = target.get(attr)
    else:  # get single attr
        dic[childAttr] = target.get(childAttr)
    return dic

# pos_kv_map stores mainly about the parent node info,tag is parent node tag, kv_map stores parent node attribute and values
# pos_kv_map,example {'tag':'writeHost','kv_map':{'host':'hostM2'}}
def get_parent_nodes_from_dic(tree, pos_kv_map):
    parentTag = pos_kv_map.get("tag").lower()
    if parentTag == "root":
        parentNodes = [tree.getroot()]
    else:
        tagNodes = tree.findall(parentTag)
        parentNodes = get_node_by_keyvalue(tagNodes, pos_kv_map.get("kv_map"))
    assert len(parentNodes) > 0, "cant not find parent tag:{0} in file {1} to insert child node".format(
        pos_kv_map.get("tag"), file)
    return parentNodes


def get_xml_from_str(str):
    return ET.fromstring("<tmproot>" + str + "\n</tmproot>")


def add_child_in_text(file, pos_kv_map, childNodeInText):
    '''file:指定的xml文件的一个节点添加子节点
       pos_kv_map: 要添加节点的定位信息，包括父节点，前节点，插入位置等，
       格式举例： {'tag':'schema','kv_map':{'name':'host1','k2':'v2'},'prev':'dataHost'}, kv_map is feature of the parentNode if exists multiple
       tag:父节点,节点
       kv_map:父节点的节点属性信息，如name:value
       prev:要添加的节点点的前一个节点名称
       childIdx:要添加的子节点的位置索引
       childNodeInText: 子节点'''
    childNode = get_xml_from_str(childNodeInText)

    add_child_in_xml(file, pos_kv_map, childNode)


def add_child_in_xml(file, pos_kv_map, childNode):
    ET.register_namespace("dble", "http://dble.cloud/")
    tree = ET.parse(file)

    parentNodes = get_parent_nodes_from_dic(tree, pos_kv_map)

    prevTag = pos_kv_map.get("prev", None)
    childIdx = pos_kv_map.get("childIdx", None)
    # add child nodes, delete the same name ones if exists
    idx = childIdx
    for parentNode in parentNodes:
        if childIdx is None and prevTag is not None:
            firstPrevNode = parentNode.find(prevTag)
            firstPrevIdx = parentNode.index(firstPrevNode)
            prevNodes = parentNode.findall(prevTag)
            idx = firstPrevIdx + len(prevNodes)

        k = 0
        for child in childNode:
            del_node_by_name(parentNode, child)
            if prevTag is None and childIdx is None:
                idx = get_Insert_Idx(parentNode, child)
                if idx == 0:
                    idx = k
            parentNode.insert(idx, child)
            k = k + idx + 1

    doctype = ""
    if file.find('rule.xml') > -1:
        doctype = '<!DOCTYPE dble:rule SYSTEM "rule.dtd">'
    elif file.find('schema.xml') > -1:
        doctype = '<!DOCTYPE dble:schema SYSTEM "schema.dtd">'
    elif file.find('server.xml') > -1:
        doctype = '<!DOCTYPE dble:server SYSTEM "server.dtd">'

    xmlstr = ET.tostring(tree, encoding="utf-8", xml_declaration=True, doctype=doctype)
    with open(file, 'wb') as f:
        f.writelines(xmlstr)


def delete_child_node(file, kv_child, kv_parent):
    ET.register_namespace("dble", "http://dble.cloud/")
    tree = ET.parse(file)

    parentTag = kv_parent.get("tag").lower()
    if parentTag == "root":
        parentNodes = [tree.getroot()]
    else:
        tagNodes = tree.findall(parentTag)
        parentNodes = get_node_by_keyvalue(tagNodes, kv_parent.get("kv_map"))

    assert len(parentNodes) > 0, "cant not find parent tag:{0} in file {1} to delete child node".format(
        kv_parent.get("tag"), file)

    for node in parentNodes:
        children = node.findall(kv_child.get("tag"))
        for child in children:
            if if_match(child, kv_child.get("kv_map")):
                node.remove(child)

    doctype = ""
    if file.find('rule.xml') > -1:
        doctype = '<!DOCTYPE dble:rule SYSTEM "rule.dtd">'
    elif file.find('schema.xml') > -1:
        doctype = '<!DOCTYPE dble:schema SYSTEM "schema.dtd">'
    elif file.find('server.xml') > -1:
        doctype = '<!DOCTYPE dble:server SYSTEM "server.dtd">'

    xmlstr = ET.tostring(tree, encoding="utf-8", xml_declaration=True, doctype=doctype)
    with open(file, 'wb') as f:
        f.writelines(xmlstr)


# delete the same name node with the given child
def del_node_by_name(node, child):
    name_to_del = child.get('name')
    if name_to_del is not None:
        name_to_del = name_to_del.lower()
    nodeChildren = node.findall(child.tag)

    for nchild in nodeChildren:
        nchild_name = nchild.get('name')
        if nchild_name is not None:
            nchild_name = nchild_name.lower()
        if nchild_name == name_to_del:
            node.remove(nchild)


def get_Insert_Idx(node, child):
    existsChildren = node.findall(child.tag)
    idx = -1
    for tagChild in existsChildren:
        tmp = node.index(tagChild)
        if tmp > idx: idx = tmp

    idx = idx + 1
    return idx

def change_node_properties(file, kv_map, is_delete=False):
    '''修改/增加 /删除 节点的属性及属性值
      nodelist: 节点列表
      kv_map:属性及属性值map'''
    ET.register_namespace("dble", "http://dble.cloud/")
    tree = ET.parse(file)
    rootnode = tree.getroot()
    for key in kv_map:
        if is_delete:
            if key in rootnode.attrib:
                del rootnode.attrib[key]
        else:
            rootnode.set(key, kv_map.get(key))
    doctype = ""
    if file.find('rule.xml') > -1:
        doctype = '<!DOCTYPE dble:rule SYSTEM "rule.dtd">'
    elif file.find('schema.xml') > -1:
        doctype = '<!DOCTYPE dble:schema SYSTEM "schema.dtd">'
    elif file.find('server.xml') > -1:
        doctype = '<!DOCTYPE dble:server SYSTEM "server.dtd">'

    xmlstr = ET.tostring(tree, encoding="utf-8", xml_declaration=True, doctype=doctype)
    with open(file, 'wb') as f:
        f.writelines(xmlstr)

if __name__ == "__main__":
    import sys

    command = sys.argv[1]
    if command == "rule":
        seg = """
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
        add_child_in_text('dble_conf/conf_template/rule.xml', {"tag": "root", "kv_map": {}}, seg)
    elif command == "schema":
        seg = """
<dataHost balance="0" maxCon="100" minCon="10" name="test-dataHost" slaveThreshold="100" switchType="1">
<heartbeat>select user()</heartbeat>
<writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
</writeHost>
</dataHost>
        """

        fullpath = "/init_assets/dble-test-suite/behave_dble/dble_conf/template/schema.xml"

        add_child_in_text(fullpath, {'tag': 'root', 'prev': "dataHost"}, seg)
    elif command == "server":
        seg = """
      <firewall>
          <whitehost>
              <host host="10.186.23.68" user="test"/>
              <host host="10.186.23.68" user="root"/>
              <host host="172.100.9.253" user="root"/>
              <host host="172.100.9.253" user="test"/>
          </whitehost>
      </firewall>
            """
        add_child_in_text('../../../dble_conf/conf_template/server.xml', {"tag": "root", "prev": 'system'}, seg)
    elif command == "delete":
        file = "dble_conf/conf_template/server.xml"
        kv_child = eval("{'tag':'user','kv_map':{'name':'mnger'}}")
        kv_parent = eval("{'tag':'root'}")
        delete_child_node(file, kv_child, kv_parent)
