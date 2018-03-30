# -*- coding: utf-8 -*-
# @Time    : 2018/3/30 PM5:54
# @Author  : zhaohongjie@actionsky.com

from xml.etree.cElementTree import ElementTree as ET

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

def add_child_node(file, parentTag, childNodeInText):
    '''file:指定的xml文件的一个节点添加子节点
       parentNodeID: 要添加节点的父节点，格式 {tag:schema,kv_map:{k1:v1,k2:v2}}
       childNodeInText: 子节点'''
    tree = ET()
    tree.parse(file=file)

    if parentTag.lower() == "root":
        parentNodes = tree.getroot()
    else:
        parentNodes = tree.findall(parentTag.tag)
    assert len(parentNodes)>0, "cant not find parent tag:{0} in file {1} to insert child node".format(parentTag, file)
    childNodeRoot = ET.fromstring("<tmproot>" + childNodeInText + "</tmproot>")

    #add child nodes, delete the same name ones if exists
    for node in parentNodes:
        for child in childNodeRoot:
            del_node_by_name(node, child)
            node.append(child)

    tree.write(file, encoding="utf-8", xml_declaration=True)

# delete the same name node with the given child
def del_node_by_name(node, child):
    nodeChildren = node.findall(child.tag)
    name_to_del = child.get('name')
    for nchild in nodeChildren:
        if nchild.get(name_to_del, None) is not None:
            node.remove(nchild)