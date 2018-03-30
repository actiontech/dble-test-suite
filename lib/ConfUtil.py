#!/usr/bin/python
# -*- coding=utf-8 -*-
# author : wklken@yeah.net
# date: 2012-05-25
# version: 0.1
# deal with xml config files -- zhj
import optparse
import sys
import re
import os
import json
from xml.etree.ElementTree import ElementTree, Element


def read_xml(in_path):
    '''''读取并解析xml文件
       in_path: xml路径
       return: ElementTree'''
    tree = ElementTree()
    tree.parse(in_path)
    return tree

def write_xml(tree, out_path):
    '''''将xml文件写出
       tree: xml树
       out_path: 写出路径'''
    tree.write(out_path, encoding="utf-8", xml_declaration=True)

def if_match(node, kv_map):
    '''''判断某个节点是否包含所有传入参数属性
       node: 节点
       kv_map: 属性及属性值组成的map'''
    for key in kv_map:
        if node.get(key) != kv_map.get(key):
            return False
    return True

# ---------------search -----
def find_nodes(tree, path):
    '''''查找某个路径匹配的所有节点
       tree: xml树
       path: 节点路径'''
    return tree.findall(path)

def get_node_by_keyvalue(nodelist, kv_map):
    '''''根据属性及属性值定位符合的节点，返回节点
       nodelist: 节点列表
       kv_map: 匹配属性及属性值map'''

    result_nodes = []
    for node in nodelist:
        if if_match(node, kv_map):
            result_nodes.append(node)
    return result_nodes

# ---------------change -----
def change_node_properties(nodelist, kv_map, is_delete=False):
    '''''修改/增加 /删除 节点的属性及属性值
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
    '''''改变/增加/删除一个节点的文本
       nodelist:节点列表
       text : 更新后的文本'''
    for node in nodelist:
        if is_add:
            node.text += text
        elif is_delete:
            node.text = ""
        else:
            node.text = text

def create_node(tag, property_map, content):
    '''''新造一个节点
       tag:节点标签
       property_map:属性及属性值map
       content: 节点闭合标签里的文本内容
       return 新节点'''
    element = Element(tag, property_map)
    element.text = content
    return element

def add_child_node(nodelist, element):
    '''''给一个节点添加子节点
       nodelist: 节点列表
       element: 子节点'''
    for node in nodelist:
        node.append(element)

def child_node_add_child_node(element1, element):
    '''''给一个节点添加子节点
       nodelist: 节点列表
       element: 子节点'''

    element1.append(element)

def del_node_by_tagkeyvalue(nodelist, tag, kv_map):
    '''''通过属性及属性值定位一个节点，并删除之
       nodelist: 父节点列表
       tag:子节点标签
       kv_map: 属性及属性值列表'''
    for parent_node in nodelist:
        children = parent_node.getchildren()
        for child in children:
            if child.tag == tag and if_match(child, kv_map):
                parent_node.remove(child)

def get_args(arg_names, has_name=False):
    if has_name:
        usage = "usage: %prog <command> <name> [options]"
    else:
        usage = "usage: %prog <command> [options]"
    parser = optparse.OptionParser(usage)
    for arg in arg_names:
        if arg[0] == '!':
            parser.add_option('', '--' + arg[1:], action="store_true")
        elif (arg[0]) == '?':
            parser.add_option('', '--' + arg[1:])
        else:
            parser.add_option('', '--' + arg)
    (options, args) = parser.parse_args()
    if has_name:
        if len(args) != 2:
            parser.print_help()
            sys.exit(1)
        name = args[1]
    else:
        if len(args) != 1:
            parser.print_help()
            sys.exit(1)
        name = ''
    for arg in arg_names:
        arg = arg.replace('-', '_')
        if arg[0] in ('!', '?'):
            continue
        if not hasattr(options, arg):
            parser.print_help()
            sys.exit(1)
    return (name, options)

def indent(element1, level=0):
    i = "\n" + level * "\t"
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "\t"
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level + 1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def replace(path, type):
    fp3 = open(path, "r")
    fp4 = open(path + "baks", "w")
    i = 0;
    for s in fp3.readlines():  # 先读出来
        if (i == 1):
            if type == 1:
                fp4.write('''<!DOCTYPE dble:rule SYSTEM "rule.dtd">''')
            elif type == 2:
                fp4.write('''<!DOCTYPE dble:server SYSTEM "server.dtd">''')
            elif type == 3:
                fp4.write('''<!DOCTYPE dble:schema SYSTEM "schema.dtd">''')
        fp4.write(s.replace("ns0", "dble"))  # 替换 并写入
        i = i + 1
    fp3.close()
    fp4.close()
    change(path)

def change(path):
    fp3 = open(path + "baks", "r")
    fp4 = open(path, "w")
    i = 0;
    for s in fp3.readlines():  # 先读出来
        fp4.write(s)  # 并写入
        i = i + 1
        # print(s)
    fp3.close()
    fp4.close()
    os.remove(path + "baks")
    # os.system("rm -rf "+path+"baks")

def read(path):
    f1 = open(path)
    print(f1.readlines());

def find_node_by_name(root, name, tag):
    for function in root.findall(tag):
        fname = function.get('name')
        # 找到对应节点
        if fname == name:
            return function
    return ''

def formatattr(attrs):
    lens = len(attrs)
    for i in range(lens):
        if attrs[lens - 1 - i].find(":") == -1:
            attrs[lens - 2 - i] = attrs[lens - 2 - i] + ',' + attrs[lens - 1 - i]
            del attrs[lens - 1 - i]
            # print(attrs)
    return attrs

def tomap(attrs):
    dic = {}

    for att in attrs:
        dic[att.split(':')[0]] = att.split(':')[1]
    return dic

def main():
    if len(sys.argv) < 2:
        usage()
        sys.exit(1)

    command = sys.argv[1]
    if command == 'createTableRule':  # 新增tablerule in rule.xml
        arg_names = [
            'path',
            'name',
            'columns',
#            'function'
            'algorithm'
        ]
        # 获取传入参数
        name, options = get_args(arg_names)
        # 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        # 创建对应的tablerule节点
        tableRule = create_node("tableRule", {"name": getattr(options, 'name')}, "")
        # 创建rule节点
        rude = create_node("rule", {}, "")
        # 创建 columns节点
        columns = create_node("columns", {}, getattr(options, 'columns'))
        # 创建 function
        algorithm = create_node("algorithm", {}, getattr(options, 'algorithm'))
        # 节点按层级添加
        rude.append(columns)
        rude.append(algorithm)
        tableRule.append(rude)
        # 将tablerule节点放在第二行
        tree.getroot().insert(1, tableRule)
        # 将更改保存到文件
        write_xml(tree, getattr(options, 'path'))
        # 增加丢失部分
        replace(getattr(options, 'path'), 1) # #
    elif command == 'editTableRule':  # 更改tablerule in rule.xml
        arg_names = [
            'path',
            'name',
            'columns',
            'algorithm'
        ]
        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        for tableRule in root.findall('tableRule'):
            name = tableRule.get('name')
            # 找到对应节点
            if name == getattr(options, 'name'):
                #print(name)
                rule = tableRule.find("rule")
                columns = rule.find("columns")
                algorithm = rule.find("algorithm")
                # 修改节点参数
                if getattr(options, 'columns') != '':
                    columns.text = getattr(options, 'columns')
                if getattr(options, 'algorithm') != '':
                    algorithm.text = getattr(options, 'algorithm')
        write_xml(tree, getattr(options, 'path'))
        replace(getattr(options, 'path'), 1)
    elif command == 'delTableRule':  # 删除tablerule节点 in rule.xml
        arg_names = [
            'path',
            'name'
        ]
        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        parent = root.findall('tableRule')
        for tableRule in parent:
            # 找到节点
            name = tableRule.get('name')
            if name == getattr(options, 'name'):
                #print(name)
                # 删除节点
                root.remove(tableRule)
        write_xml(tree, getattr(options, 'path'))
        replace(getattr(options, 'path'), 1)
    elif command == 'createFunction':  # 创建function in rule.xml
        arg_names = [
            'path',
            'class',
            'name',
            'propertys'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        # 创建function
        function = create_node("function", {"class": getattr(options, 'class'), "name": getattr(options, 'name')}, "")
        map = getattr(options, 'propertys').split(',')
        maps = formatattr(map)
        for property in maps:
            # 创建property并且赋值
            name = property.split(':')[0]
            text = property.split(':')[1]
            newproperty = create_node("property", {"name": name}, text)
            function.append(newproperty)
        # 将function加入根目录下
        tree.getroot().append(function)
        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # 添加缺省值
        replace(getattr(options, 'path'), 1)
    elif command == 'editFunction':  # 创建function in rule.xml
        arg_names = [
            'path',
            'name',
            'propertys'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        function = find_node_by_name(root, getattr(options, 'name'), 'function')
        map = getattr(options, 'propertys').split(',')
        maps = formatattr(map)
        i = 0
        for pro in maps:
            name = pro.split(':')[0]
            text = pro.split(':')[1]
            if i > 0:
                newproperty = create_node("property", {"name": name}, text)
                i = 0
                function.append(newproperty)
            for property in function.findall("property"):
                pname = property.attrib.get("name")
                if name == pname:
                    if text:
                        property.text = text
                        i = i + 1

                    else:
                        #print(text)
                        function.remove(property)
                        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # 添加缺省值
        replace(getattr(options, 'path'), 1)
    elif command == 'delFunction':  # 删除tablerule节点 in rule.xml
        arg_names = [
            'path',
            'name'
        ]
        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        parent = root.findall('function')
        for function in parent:
            # 找到节点
            name = function.get('name')
            if name == getattr(options, 'name'):
                #print(name)
                # 删除节点
                root.remove(function)
        write_xml(tree, getattr(options, 'path'))
        replace(getattr(options, 'path'), 1)
    elif command == 'createProperty':  # 添加property节点 in server.xml
        arg_names = [
            'path',
            'name',
            'text'
        ]
        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        functions = root.findall('system')
        newproperty = create_node("property", {"name": getattr(options, 'name')}, getattr(options, 'text'))
        functions[0].append(newproperty)
        write_xml(tree, getattr(options, 'path'))
        replace(getattr(options, 'path'), 2)
    elif command == 'editOrDelProperty':  # edit or delete property节点 in server.xml
        arg_names = [
            'path',
            'name',
            'text'
        ]
        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        system = root.findall('system')
        propertys = system[0].findall('property')
        for property in propertys:
            if property.attrib.get('name') == getattr(options, 'name'):
                if getattr(options, 'text') == '':
                    system[0].remove(property)
                else:
                    property.text = getattr(options, 'text')

        write_xml(tree, getattr(options, 'path'))
        replace(getattr(options, 'path'), 2)
    elif command == 'createUser':  # 创建user in server.xml
        arg_names = [
            'path',
            'name',
            'propertys'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        # 创建function
        user = create_node("user", {"name": getattr(options, 'name')}, "")
        map = getattr(options, 'propertys').split(',')
        maps = formatattr(map)
        for property in maps:
            # 创建property并且赋值
            name = property.split(':')[0]
            text = property.split(':')[1]
            newproperty = create_node("property", {"name": name}, text)
            user.append(newproperty)
        # 将user加入根目录下
        tree.getroot().append(user)
        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # 添加缺省值
        replace(getattr(options, 'path'), 2)
    elif command == 'editUser':  # edit function in server.xml
        arg_names = [
            'path',
            'name',
            'propertys'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        user = find_node_by_name(root, getattr(options, 'name'), 'user')
        map = getattr(options, 'propertys').split(',')
        maps = formatattr(map)
        i = 0
        for pro in maps:
            name = pro.split(':')[0]
            text = pro.split(':')[1]
            if i > 0:
                newproperty = create_node("property", {"name": name}, text)
                i = 0
                user.append(newproperty)
            for property in user.findall("property"):
                pname = property.attrib.get("name")
                if name == pname:
                    if text:
                        property.text = text
                        i = i + 1

                    else:
                        #print(text)
                        user.remove(property)
                        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # 添加缺省值
        replace(getattr(options, 'path'), 2)
    elif command == 'delUser':  # 删除user节点 in server.xml
        arg_names = [
            'path',
            'name'
        ]
        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        parent = root.findall('user')
        for user in parent:
            # 找到节点
            name = user.get('name')
            if name == getattr(options, 'name'):
                #print(name)
                # 删除节点
                root.remove(user)
        write_xml(tree, getattr(options, 'path'))
        replace(getattr(options, 'path'), 2)
    elif command == 'createUserPrivilege':  # 创建user in server.xml
        arg_names = [
            'path',
            'privileges',
            'schemas',
            'tables'
        ]
        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        users = root.findall('user')
        privilege = getattr(options, 'privileges')
        schemas = getattr(options, 'schemas')
        tables = getattr(options, 'tables')

        for user in users:
            map = privilege.split(',')
            if if_match(user, {'name': map[0].split(':')[1]}):
                privilegeNode = create_node("privileges", {"check": map[1].split(':')[1]}, '')
                schemasmap = schemas.split('&')
                for schema in schemasmap:
                    key = schema.split(',')
                    kvmap = tomap(key)
                    schemaNode = create_node("schema", kvmap, "")
                    if not tables == '':
                        table_all = str(tables).split('&')
                        for table in table_all:
                            tablekey = table.split(',')
                            if tablekey[0].split(":")[1] == key[0].split(":")[1]:
                                tablekvmap = tomap(tablekey[1:])
                                tableNode = create_node("table", tablekvmap, "")
                                schemaNode.append(tableNode)
                    privilegeNode.append(schemaNode)
                user.append(privilegeNode)
                # tree.getroot().append(user)
        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # 添加缺省值
        replace(getattr(options, 'path'), 2)
    elif command == 'delUserPrivileges':  # 删除privileges节点 in server.xml
        arg_names = [
            'path',
            'name'
        ]
        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        parent = root.findall('user')
        for user in parent:
            # 找到节点
            name = user.get('name')
            if name == getattr(options, 'name'):
                #print(name)
                # 删除节点
                #root.remove(user)
                for privilege in user.findall("privileges"):
                    user.remove(privilege)
        write_xml(tree, getattr(options, 'path'))
        replace(getattr(options, 'path'), 2)
    elif command == 'createFirewall':   # 创建user in server.xml
        arg_names = [
            'path',
            'hosts',
            'blacklist',
            'propertys',
            'values'
        ]
        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        firewallNode = create_node("firewall", {}, "")
        hosts = getattr(options, 'hosts')
        blacklist = getattr(options, 'blacklist')
        propertys = getattr(options, 'propertys')
        values = getattr(options, 'values')

        if hosts.strip():
            whitehostNode = create_node("whitehost", {}, "")
            hosts = hosts.split('&')
            for host in hosts:
                hostNode = create_node("host", tomap(host.split(',')), "")
                whitehostNode.append(hostNode)
            firewallNode.append(whitehostNode)

        if blacklist.strip():
            blacklistNode = create_node("blacklist", tomap(blacklist.split(',')), "")
            propertys = propertys.split('&')
            values = values.split('&')
            for propertd in propertys:
                propertyNode = create_node("property", tomap(propertd.split(',')), "")
                for value in values:
                    if value.split(",")[0].split(":")[1] == propertd.split(":")[1]:
                        change_node_text(propertyNode, value.split(",")[1].split(":")[1])
                blacklistNode.append(propertyNode)
            firewallNode.append(blacklistNode)
        #root.append(firewallNode)
        tree.getroot().insert(1, firewallNode)
        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # 添加缺省值
        replace(getattr(options, 'path'), 2)
    elif command == "delFirewall": # in server.xml
        arg_names = [
            'path'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        firewalls = root.findall('firewall')
        for firewall in firewalls:
            root.remove(firewall)
                # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 2)
    elif command == 'createSchema':  # 创建 schema in schema.xml
        arg_names = [
            'path',
            'name',
            'attributes'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        attr = getattr(options, 'attributes').split(',')
        attrs = formatattr(attr)
        map = {}
        map['name'] = getattr(options, 'name')
        if str(attr).strip():
            for att in attrs:
                name = att.split(':')[0]
                value = att.split(':')[1]
                map[name] = value

        # 创建function
        schema = create_node("schema", map, "")
        tree.getroot().insert(1, schema)
        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'delSchema':  # delete schema in schema.xml
        arg_names = [
            'path',
            'name'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        schemas = root.findall('schema')
        # 创建function
        for schema in schemas:
            # 找到节点
            name = schema.get('name')
            if name == getattr(options, 'name'):
                #print(name)
                # 删除节点
                root.remove(schema)

                # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'createTable':  # in schema.xml
        arg_names = [
            'path',
            'schemaName',
            'attributes'

        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        # 创建function
        attr = getattr(options, 'attributes').split(',')
        attrs = formatattr(attr)
        map = {}
        for att in attrs:
            name = att.split(':')[0]
            value = att.split(':')[1]
            map[name] = value

        schemas = tree.findall("schema")  # find_nodes(tree, "schema")
        table = create_node("table", map, "")
        for schema in schemas:
            # 找到节点
            name = schema.get('name')
            if name == getattr(options, 'schemaName'):
                #print(name)
                # 节点
                schema.append(table)

                # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'editTable':  # in schema.xml
        arg_names = [
            'path',
            'schemaName',
            'tableName',
            'attributes'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        # 创建function
        attr = getattr(options, 'attributes').split(',')
        maps = {}
        dmap = {}
        attrs = formatattr(attr)
        for att in attrs:
            name = att.split(':')[0]
            value = att.split(':')[1]
            if value == '':
                dmap[name] = value
            else:
                maps[name] = value

        tables = find_nodes(tree, "schema/table")
        # B. 通过属性准确定位子节点
        table = get_node_by_keyvalue(tables, {"name": getattr(options, 'tableName')})
        #print(table)
        change_node_properties(table, maps)
        change_node_properties(table, dmap, True)

        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'delTable':  # in schema.xml
# bug：delTable接口：会删除所有schema里的指定表 -- fenghua
        arg_names = [
            'path',
            'schemaName',
            'name'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))

        schemas = find_nodes(tree, "schema")
        del_node_by_tagkeyvalue(schemas, "table", {"name": getattr(options, 'name')})
        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'createChildTable':  # in schema.xml
        arg_names = [
            'path',
            'schemaName',
            'tableName',
            'childTables',
            'attributes'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        # 创建function
        attr = getattr(options, 'attributes').split(',')
        attrs = formatattr(attr)
        map = {}
        load = 'schema/table'
        fa_name = ''
        for att in attrs:
            name = att.split(':')[0]
            value = att.split(':')[1]
            map[name] = value
        if getattr(options, 'childTables') != '':
            ct = getattr(options, 'childTables').split(',')
            for ld in ct:
                load = load + "/" + 'childTable'
                fa_name = ld

        childTable = create_node("childTable", map, "")

        # A. 找到父节点
        nodes = find_nodes(tree, load)

        if getattr(options, 'childTables') != '':
            fa_nodes = get_node_by_keyvalue(nodes, {"name": fa_name})
        else:
            fa_nodes = get_node_by_keyvalue(nodes, {"name": getattr(options, 'tableName')})
        add_child_node(fa_nodes, childTable)
        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'editChildTable':  # in schema.xml
        arg_names = [
            'path',
            'schemaName',
            'tableName',
            'childTables',
            'attributes'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        # 创建function
        attr = getattr(options, 'attributes').split(',')
        maps = {}
        dmap = {}
        attrs = formatattr(attr)
        for att in attrs:
            name = att.split(':')[0]
            value = att.split(':')[1]
            if value == '':
                dmap[name] = value
            else:
                maps[name] = value
        child_name = ''
        load = 'schema/table'

        if getattr(options, 'childTables') != '':
            ct = getattr(options, 'childTables').split(',')
            for ld in ct:
                child_name = ld
                load = load + '/childTable'

        childTables = find_nodes(tree, load)
        # B. 通过属性准确定位子节点

        table = get_node_by_keyvalue(childTables, {"name": child_name})
        print(table)
        change_node_properties(table, maps)
        change_node_properties(table, dmap, True)
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'delChildTable':  # in schema.xml
        arg_names = [
            'path',
            'schemaName',
            'tableName',
            'childTables',
            'childName'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        # 创建function

        child_name = ''
        i = 0
        load = 'schema/table'
        ct = getattr(options, 'childTables').split(',')
        if getattr(options, 'childTables') != '':

            for ld in ct:
                child_name = ld
                if i > 0:
                    load = load + '/childTable'
                i = i + 1
        #print(load)
        nodes = find_nodes(tree, load)
        if i > 1:
            fa_nodes = get_node_by_keyvalue(nodes, {"name": ct[len(ct) - 1]})

        else:
            fa_nodes = get_node_by_keyvalue(nodes, {"name": getattr(options, 'tableName')})
            # print(fa_nodes)
        target_del_node = del_node_by_tagkeyvalue(fa_nodes, "childTable", {"name": getattr(options, 'childName')})
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'createDataNode':  # in schema.xml
        arg_names = [
            'path',
            'name',
            'dataHost',
            'database'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        schemas = root.findall('schema')
        # 创建function
        dataNode = create_node("dataNode", {"name": getattr(options, 'name'), "dataHost": getattr(options, 'dataHost'),
                                            "database": getattr(options, 'database')}, "")
        tree.getroot().insert(len(schemas), dataNode)
        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'delDataNode':  # in schema.xml
        arg_names = [
            'path',
            'name'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        dataNodes = root.findall('dataNode')
        # 创建function
        for dataNode in dataNodes:
            # 找到节点
            name = dataNode.get('name')
            if name == getattr(options, 'name'):
                print(name)
                # 删除节点
                root.remove(dataNode)

                # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'createDataHost':  # in schema.xml
        arg_names = [
            'path',
            'name',
            'balance',
            'maxCon',
            'minCon',
            'slaveThreshold',
            'switchType',
            'writeType'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        schemas = root.findall('schema')
        dataNodes = root.findall('dataNode')
        # 创建function
        dataHost = create_node("dataHost", {"name": getattr(options, 'name'),
                                            "balance": getattr(options, 'balance'),
                                            "maxCon": getattr(options, 'maxCon'),
                                            "minCon": getattr(options, 'minCon'),
                                            "slaveThreshold": getattr(options, 'slaveThreshold'),
                                            "switchType": getattr(options, 'switchType'),
                                            "writeType": getattr(options, 'writeType')}, "")
        tree.getroot().insert(len(schemas) + len(dataNodes), dataHost)
        # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
    elif command == 'delDataHost':  # in schema.xml
        arg_names = [
            'path',

            'name'
        ]

        name, options = get_args(arg_names)
        # 1. 读取xml文件
        tree = read_xml(getattr(options, 'path'))
        root = tree.getroot()
        dataHosts = root.findall('dataHost')
        # 创建function
        for dataHost in dataHosts:
            # 找到节点
            name = dataHost.get('name')
            if name == getattr(options, 'name'):
                print(name)
                # 删除节点
                root.remove(dataHost)

                # 保存文件
        write_xml(tree, getattr(options, 'path'))
        # #添加缺省值
        replace(getattr(options, 'path'), 3)
if __name__ == "__main__":
    # 1. 读取xml文件
    # tree = read_xml("C:\\Users\\Action\Desktop\\usefortest\\test.xml")


    # 2. 属性修改
    # A. 找到父节点
    # nodes = find_nodes(tree, "processers/processer")
    # B. 通过属性准确定位子节点
    # result_nodes = get_node_by_keyvalue(nodes, {"name":"BProcesser"})

    # C. 修改节点属性
    # change_node_properties(result_nodes, {"age": "1"})
    # D. 删除节点属性
    # change_node_properties(result_nodes, {"value":""}, True)
    # change_node_properties(result_nodes, {"value":""}, True)

    # 3. 节点修改
    # A.新建节点
    # a = create_node("person", {"age":"15","money":"200000"}, "this is the firest content")
    # B.插入到父节点之下
    # add_child_node(result_nodes, a)

    # 4. 删除节点
    # 定位父节点
    # del_parent_nodes = find_nodes(tree, "processers/services/service")
    # 准确定位子节点并删除之
    # target_del_node = del_node_by_tagkeyvalue(del_parent_nodes, "chain", {"sequency" : "chain1"})

    # 5. 修改节点文本
    # 定位节点
    # text_nodes = get_node_by_keyvalue(find_nodes(tree, "processers/services/service/chain"), {"sequency":"chain3"})
    # change_node_text(text_nodes, "new text")

    # 6. 输出到结果文件
    # write_xml(tree, "./test1.xml")
    main()