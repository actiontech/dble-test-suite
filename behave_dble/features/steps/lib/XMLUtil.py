# -*- coding: utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
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


def get_child_nodes(parentNode, childNode_info, file):
    """
    to get a node featured childNode_info, and parent node is parentNode from the file
    :param parentNode: target node's parent node
    :param childNode_info: target node's feature, tag is a must feature, kv_map is optional feature, eg:{'tag':'dataHost','kv_map':{'name': 'ha_group1','balance':'0'}}
    :param file: the xml file
    :return:
    """
    tree = ET.parse(file)
    parentNodes = get_parent_nodes(tree, parentNode)
    childTag = childNode_info.get("tag")

    targets = None
    for node in parentNodes:
        children = node.findall(childTag)
        targets = get_node_by_keyvalue(children, childNode_info.get("kv_map"))
        if len(targets) == 1: break

    assert targets, "get node attribute fail, no targets node found"

    return targets


def get_parent_nodes(tree, pos_kv_map):
    """
    :param tree:
    :param pos_kv_map: stores mainly about the parent node info,tag is parent node tag, kv_map stores parent node attribute and values,example {'tag':'writeHost','kv_map':{'host':'hostM2'}}
    :return: parent nodes
    """
    parentTag = pos_kv_map.get("tag")
    if parentTag.lower() == "root":
        parentNodes = [tree.getroot()]
    else:
        parentNodesRaw = tree.findall(parentTag)
        parentNodes = get_node_by_keyvalue(parentNodesRaw, pos_kv_map.get("kv_map"))
    assert len(parentNodes) > 0, "cant not find parent tag:{0} to insert child node".format(
        pos_kv_map.get("tag"))
    return parentNodes


def get_xml_from_str(str):
    return ET.fromstring("<tmproot>" + str + "\n</tmproot>")


def add_child_in_string(file, pos_kv_map, childNodeInString):
    """
    add child to file or to file content in memory
    :param pos_kv_map: the pos info for node to add, including parent node info, prev node info, insertion position, etc. Example:{'tag':'schema','kv_map':{'name':'host1','k2':'v2'},'prev':'dataHost'}, kv_map is feature of the parentNode if exists multiple, tag is the parent node tag, it is must, prev is node tag for the node to add
    :param childNodeInString: child node xml in string format
    :param file_local: xml file name in local
    :param file_content: xml content
    :return: if file_local is not None, return none, elif file_content is not None, return xmlStr
    """
    childNode = get_xml_from_str(childNodeInString)
    return add_child_in_xml(file, pos_kv_map, childNode)


def add_child_in_xml(file, pos_kv_map, childNode):
    """
    for each child to insert, insert position priority: same name node index > max(same tag index) > lastInsertTypeNodeMaxIdx
    :param file:
    :param pos_kv_map: the child node's position info, eg:{'tag':'root',"prev": 'dataNode'}, root is parent node tag, child's prev node tag is dataNode
    :param childNode:
    """
    ET.register_namespace("dble", "http://dble.cloud/")
    tree = ET.parse(file)

    parentNodes = get_parent_nodes(tree, pos_kv_map)

    prevTag = pos_kv_map.get("prev", None)

    for parentNode in parentNodes:
        idxByPrevNode = 0
        if prevTag:
            firstPrevNode = parentNode.find(prevTag)
            firstPrevIdx = parentNode.index(firstPrevNode)
            prevNodes = parentNode.findall(prevTag)
            idxByPrevNode = firstPrevIdx + len(prevNodes)

        k = 0
        firstLoop = True
        for child in childNode:
            # delete the same name nodes,and get the first deleted node idx
            firstDelIdx = del_node_by_name(parentNode, child)

            # find same tag node count
            sameTagChildMaxIdx = get_Insert_Idx(parentNode, childNode[0])

            if firstDelIdx == -1 and sameTagChildMaxIdx == 0:  # there is no same tag
                if firstLoop:
                    if prevTag is None:  # for the first child to insert,if no prev node, insert index is 0
                        idx = 0
                    else:
                        idx = idxByPrevNode
                else:  # not first child, insert as last of parentNode
                    idx = k
            else:
                if firstDelIdx == -1:  # there is no same name tag, insert as last of same tag
                    idx = sameTagChildMaxIdx
                else:  # there is same name tag, insert at the same name tag
                    idx = firstDelIdx
            # print "debug6: idx ", idx, "child,", child.get('name')
            parentNode.insert(idx, child)

            k = get_Insert_Idx(parentNode,
                               child)  # lastInsertTypeNodeMaxIdx, prepare for next child which has no same tag
            firstLoop = False

    doctype = ""
    if file.find('db.xml') > -1:
        doctype = '<!DOCTYPE dble:db SYSTEM "db.dtd">'
    elif file.find('sharding.xml') > -1:
        doctype = '<!DOCTYPE dble:sharding SYSTEM "sharding.dtd">'
    elif file.find('user.xml') > -1:
        doctype = '<!DOCTYPE dble:user SYSTEM "user.dtd">'

    xmlstr = ET.tostring(tree, encoding="utf-8", xml_declaration=True, doctype=doctype)
    with open(file, 'wb') as f:
        f.writelines(xmlstr)


def delete_child_node(file, kv_child, kv_parent):
    """
    delete child nodes featured by kv_child while child's parent are featured by kv_parent
    if kv_parent is root means parent is the top level node
    if kv_child is root means delete all nodes in parent
    :param file: xml file to deal
    :param kv_child: only delete child with features in kv_child
    :param kv_parent: only delete child of parent with features in kv_parent
    """
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

    childTag = kv_child.get("tag")
    for node in parentNodes:
        if childTag == "root":  # delete all children
            children = node.getchildren()
        else:  # delete certain children
            children = node.findall(childTag)
        for child in children:
            if if_match(child, kv_child.get("kv_map")):
                node.remove(child)

    doctype = ""
    if file.find('db.xml') > -1:
        doctype = '<dble:db xmlns:dble="http://dble.cloud/">'
    elif file.find('sharding.xml') > -1:
        doctype = '<!DOCTYPE dble:sharding SYSTEM "sharding.dtd">'
    elif file.find('user.xml') > -1:
        doctype = '<!DOCTYPE dble:user SYSTEM "user.dtd">'

    xmlstr = ET.tostring(tree, encoding="utf-8", xml_declaration=True, doctype=doctype)
    with open(file, 'wb') as f:
        f.writelines(xmlstr)


def del_node_by_name(node, child):
    """
    delete the same name node with the given child
    :param node: parent node
    :param child: featured child node which gives node tag and name by which to delete
    :return:firstDelNodeIndex if exists, else -1
    """
    name_to_del = child.get('name')
    if name_to_del is not None:
        name_to_del = name_to_del.lower()
    nodeChildren = node.findall(child.tag)

    firstEnter = True
    firstDelNodeIndex = -1
    for nchild in nodeChildren:
        nchild_name = nchild.get('name')
        if nchild_name is not None:
            nchild_name = nchild_name.lower()
        if nchild_name == name_to_del:
            if firstEnter:
                firstDelNodeIndex = node.index(nchild)
                firstEnter = False
            node.remove(nchild)

    return firstDelNodeIndex


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
    if file.find('sharding.xml') > -1:
        doctype = '<!DOCTYPE dble:sharding SYSTEM "sharding.dtd">'
    elif file.find('db.xml') > -1:
        doctype = '<!DOCTYPE dble:db SYSTEM "db.dtd">'
    elif file.find('user.xml') > -1:
        doctype = '<!DOCTYPE dble:user SYSTEM "user.dtd">'

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
        add_child_in_string('dble_conf/conf_template/rule.xml', {"tag": "root", "kv_map": {}}, seg)
    elif command == "schema":
        seg = """
        <schema dataNode="dn2" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn2,dn4" name="test2" type="global" />
        </schema>
        <dataNode dataHost="ha_group1" database="db1" name="dn2" />
        <dataNode dataHost="ha_group1" database="db2" name="dn4" />
        <dataHost balance="1" maxCon="100" minCon="10" name="ha_group1" slaveThreshold="100" >
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="true"></writeHost>
        </dataHost>
        """

        fullpath = "../../../dble_conf/template_bk/schema.xml"

        add_child_in_string(fullpath, {'tag': 'root'}, seg)
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
        add_child_in_string('../../../dble_conf/template_bk/server.xml', {"tag": "root", "prev": 'system'}, seg)
    elif command == "delete":
        file = "../../../dble_conf/template_bk/server.xml"
        kv_child = eval("{'tag':'root'}")
        kv_parent = eval("{'tag':'root'}")
        delete_child_node(file, kv_child, kv_parent)
