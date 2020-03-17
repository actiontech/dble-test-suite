#coding= 'utf8'
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import MySQLdb
import logging

from behave import *
from hamcrest import *
from lib.DBUtil import DBUtil
from lib.Node import get_node, get_sftp
from lib.XMLUtil import add_child_in_string, delete_child_node, get_xml_from_str, add_child_in_xml,change_root_node_properties

LOGGER = logging.getLogger('steps.reload')

def get_dble_conn(context, default_db="schema1", node=None):
    if node is None:
        node = get_node(context.dbles, "dble-1")
    conn = DBUtil(node.ip, context.cfg_dble['client_user'],
                         context.cfg_dble['client_password'], default_db, context.cfg_dble['client_port'],
                         context)
    return conn

def get_dble_connect(context,host_name,default_db="schema1"):
    node = get_node(context.dbles, host_name)
    conn = DBUtil(node.ip, context.cfg_dble['client_user'],
                  context.cfg_dble['client_password'], default_db, context.cfg_dble['client_port'],
                  context)
    return conn

def get_admin_conn(context, user="", passwd=""):
    if len(user.strip()) == 0:
        user = context.cfg_dble['manager_user']
    if len(passwd.strip()) == 0:
        passwd = str(context.cfg_dble['manager_password'])

    conn = None
    try:
        conn = DBUtil(context.cfg_dble['dble']['ip'], user, passwd, "", context.cfg_dble['manager_port'],context)
    except MySQLdb.Error, e:
        assert False, "create manager conn meets error:{0}".format(e.args)
    return conn

@When('execute admin cmd "{adminsql}" success')
def step_impl(context, adminsql):
    exec_admin_cmd(context, adminsql)

@Given('execute admin cmd "{adminsql}" success')
@Then('execute admin cmd "{adminsql}"')
@Then('execute admin cmd "{adminsql}" get the following output')
@Then('execute admin cmd "{adminsql}" with user "{user}" passwd "{passwd}"')
@Then('execute admin cmd "{adminsql}" with "{result}" result')
def exec_admin_cmd(context, adminsql, user="", passwd="", result=""):
    if len(user.strip()) == 0:
        user = context.cfg_dble['manager_user']
    if len(passwd.strip()) == 0:
        passwd = str(context.cfg_dble['manager_password'])
    if len(result.strip()) != 0:
        adminsql = "{0} {1}".format(adminsql, getattr(context, result)[0][0])
    if context.text: expect = context.text
    else: expect = "success"

    context.execute_steps(u"""
    Then execute sql in "dble-1" in "admin" mode
        | user    | passwd | conn    | toClose | sql      | expect   | db |
        | {0}     | {1}    | new     | True    | {2}      | {3}      |    |
    """.format(user, passwd, adminsql, expect))
@Then('get resultset of admin cmd "{adminsql}" named "{rs_name}"')
def step_impl(context, adminsql, rs_name):
    manager_conn = get_admin_conn(context)
    result, error = manager_conn.query(adminsql)
    assert error is None, "execute adminsql {0}, get error:{1}".format(adminsql, error)
    setattr(context, rs_name, result)

@Then('get resultset of user cmd "{sql}" named "{rs_name}"')
@Then('get resultset of user cmd "{sql}" named "{rs_name}" with connection "{conn_type}"')
def step_impl(context, sql, rs_name, conn_type=''):
    if hasattr(context, conn_type):
        dble_conn = getattr(context, conn_type)
        LOGGER.debug("get dble_conn: {0}".format(conn_type))
    else:
        dble_conn = get_dble_conn(context)
    result, error = dble_conn.query(sql)
    assert error is None, "execute usersql {0}, get error:{1}".format(sql, error)
    setattr(context, rs_name, result)

@Then('get result of user cmd "{sql}" named "{rs_name}" in dble "{host_name}"')
def step_impl(context, sql, rs_name, host_name):
    dble_conn = get_dble_connect(context, host_name)
    result, error = dble_conn.query(sql)
    assert error is None, "execute usersql {0}, get error:{1}".format(sql, error)
    setattr(context, rs_name, result)

@Then('get resultset of cmd "{sql}" named "{rs_name}" in mysql "{host_name}"')
def step_impl(context, sql, rs_name, host_name):
    node = get_node(context.mysqls, host_name)
    ip = node._ip
    port = node._mysql_port
    user = "test"
    passwd = "111111"
    db = ""
    conn = DBUtil(ip, user, passwd, db, port, context)
    result,error = conn.query(sql)
    assert error is None, "execute usersql {0}, get error:{1}".format(sql, error)
    setattr(context,rs_name,result)


@Then('removal result set "{rs_name}" contains "{key_word}" part')
def step_impl(context, rs_name, key_word):
    rs_A = getattr(context, rs_name)
    rs_end = []
    for row_A in rs_A:
        if str(row_A).rfind(key_word) != -1:
            continue
        else:
            rs_end.append(row_A)
    setattr(context, rs_name, rs_end)

@Given('encrypt passwd and add xml segment to node with attribute "{kv_map_str}" in "{file}"')
def step_impl(context, kv_map_str, file):
    xmlSeg = get_xml_from_str(context.text)
    users = xmlSeg.findall('user')
    for user in users:
        need_encrypt = False
        for prop in user.getchildren():
            if prop.get('name', None) == 'usingDecrypt':
                need_encrypt = prop.text.strip() == '1'
                break;
        if need_encrypt:
            for prop in user.getchildren():
                if prop.get('name', None) == 'password':
                    encrypt_string = "0:{0}:{1}".format(user.get('name'), prop.text)
                    prop.text = get_encrypt(context, encrypt_string)

    fullpath = get_abs_path(context, file)
    kv_map = eval(kv_map_str)
    add_child_in_xml(fullpath, kv_map, xmlSeg)
    upload_and_replace_conf(context, file)

@Given('add xml segment to node with attribute "{kv_map_str}" in "{file}"')
def add_xml_segment(context, kv_map_str, file):
    fullpath = get_abs_path(context, file)
    kv_map = eval(kv_map_str)
    add_child_in_string(fullpath, kv_map, context.text)
    upload_and_replace_conf(context, file)

@Given('add attribute "{kv_map_str}" to rootnode in "{file}"')
def add_attr_to_node(context, file, kv_map_str):
    fullpath = get_abs_path(context, file)
    kv_map = eval(kv_map_str)
    change_root_node_properties(fullpath, kv_map)
    upload_and_replace_conf(context, file)

@Given('add current version from var "{var_name}" to rootnode in "{file}"')
def step_impl(context, var_name, file):
    current_version=getattr(context, var_name)
    kv_map_str= "{{'version':'{0}'}}".format(current_version)

    add_attr_to_node(context, file, kv_map_str)

@Given('delete the following xml segment')
def delete_xml_segment(context):
    files = []
    for row in context.table:
        file = row['file']
        files.append(file)
        fullpath = get_abs_path(context, file)
        kv_child = eval(row['child'])
        kv_parent = eval(row['parent'])

        delete_child_node(fullpath, kv_child, kv_parent)

    files.sort()
    lastfile = ""
    for file in files:
        if lastfile == file:
            continue
        else:
            upload_and_replace_conf(context, file)
        lastfile = file

@When('Add some data in "{mapFile}"')
def add_file(context,mapFile):
    targetFile = "{0}/dble/conf/{1}".format(context.cfg_dble['install_dir'], mapFile)
    text = str(context.text)
    cmd = "echo '{0}' > {1}".format(text, targetFile)
    rc, sto, err = context.ssh_client.exec_command(cmd)
    assert_that(err, is_(''), "expect no err, but err is: {0}".format(err))

@When('Execute "{cmd}" on the managerment client and check system property with "{name}","{text}"')
def check_sys_property(context, cmd, name, text):
    manager_conn = get_admin_conn(context)
    flag = "failure"
    result, error = manager_conn.query(cmd)
    if type(result) == tuple:
        for i in range(len(result)):
            if result[i][0] == name and result[i][1] == text:
                flag = "succeed"
    assert_that(flag, has_string('succeed'), "expect flag contains 'succeed', but flag is: {0}".format(flag))

def get_abs_path(context, file):
    path = "{0}/{1}".format(context.dble_conf, file)
    return path

def upload_and_replace_conf(context, filename, host='dble-1'):
    local_file = get_abs_path(context, filename)
    remote_file = "{0}/dble/conf/{1}".format(context.cfg_dble['install_dir'],filename)
    if host == 'dble-1':
        context.ssh_sftp.sftp_put(local_file, remote_file)
    else:
        sftpClient = get_sftp(context.dbles, host)
        sftpClient.sftp_put(local_file, remote_file)

def get_encrypt(context, string):
    cmd = "source /etc/profile && sh {0}/dble/bin/encrypt.sh {1}".format(context.cfg_dble['install_dir'], string)

    rc, sto, ste = context.ssh_client.exec_command(cmd)
    return sto.split('\n')[1]


@Then('execute cmd "{cmd}" with "{result}" in mysql "{host}"')
def step_impl(context, cmd, result, host):
    node = get_node(context.mysqls, host)
    ip = node._ip
    port = node._mysql_port
    user = "test"
    passwd = "111111"
    db = ""
    conn = DBUtil(ip, user, passwd, db, port, context)
    if hasattr(context, result):
        for r in getattr(context,result):
            adminsql = "{0} {1}".format(cmd, r[3])
            conn.query(adminsql)

@Given('get config xml version from template config and named as "{var_version}"')
def step_impl(context, var_version):
    cmd_server_version = "grep '<dble:server' {0}/dble/conf/server_template.xml| grep -o 'version=\".*\"' | grep -o '[0-9]*\.[0-9]*'".format(context.cfg_dble['install_dir'])
    cmd_schema_version = "grep '<dble:schema' {0}/dble/conf/schema_template.xml| grep -o 'version=\".*\"' | grep -o '[0-9]*\.[0-9]*'".format(context.cfg_dble['install_dir'])
    cmd_rule_version = "grep '<dble:rule' {0}/dble/conf/rule_template.xml| grep -o 'version=\".*\"' | grep -o '[0-9]*\.[0-9]*'".format(context.cfg_dble['install_dir'])

    rc1, sto1, ste1 = context.ssh_client.exec_command(cmd_server_version)
    rc2, sto2, ste2 = context.ssh_client.exec_command(cmd_schema_version)
    rc3, sto3, ste3 = context.ssh_client.exec_command(cmd_rule_version)

    assert sto1==sto2==sto3, "versions in server_template.xml schema_template.xml rule_template.xml are not the same"
    setattr(context, var_version, sto1)

@Then('record reloadTime of "{tbName}" from "{rs_name}" named "{rtName}"')
def record_time(context, tbName, rs_name, rtName):
    rs = getattr(context, rs_name)
    count = 0
    for rs_row in rs:
        if rs_row[1]==tbName:
            count = count+1
            reload_time = rs_row[2].replace("/","-")
            setattr(context,rtName,reload_time)
            break
    assert count != 0, "{0} is not found !".format(tbName)

@Then('get resultset when reload time "{compare}" record time "{rtName}" named "{rs_name}"')
def step(context, compare, rtName, rs_name):
    rtn=getattr(context,rtName)
    comp = ''
    if compare == 'equal':
        comp = '='
    elif compare == 'lt':
        comp = "<="
    elif compare == 'gt':
        comp = '>='
    else: assert comp != '',"Comparison operator must from [{0}, {1}, {2}]".format("equal","lt","gt")
    adminsql = "check full @@metadata where reload_time{0}'{1}'".format(comp,rtn)
    manager_conn = get_admin_conn(context)
    result, error = manager_conn.query(adminsql)
    assert error is None, "execute adminsql {0}, get error:{1}".format(adminsql, error)
    setattr(context, rs_name, result)