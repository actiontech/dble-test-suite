#coding= 'utf8'
import MySQLdb
import logging

from behave import *
from hamcrest import *
from lib.DBUtil import DBUtil
from lib.Node import get_node
from lib.XMLUtil import add_child_in_text, delete_child_node, get_xml_from_str, add_child_in_xml

LOGGER = logging.getLogger('steps.reload')

def get_dble_conn(context, default_db="schema1", node=None):
    if node is None:
        node = get_node(context.dbles, "dble-1")
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

@Then('execute admin cmd "{adminsql}"')
@Then('execute admin cmd "{adminsql}" get the following output')
@Then('execute admin cmd "{adminsql}" with user "{user}" passwd "{passwd}"')
def exec_admin_cmd(context, adminsql, user="", passwd=""):
    if len(user.strip()) == 0:
        user = context.cfg_dble['manager_user']
    if len(passwd.strip()) == 0:
        passwd = str(context.cfg_dble['manager_password'])

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
    add_child_in_text(fullpath, kv_map, context.text)
    upload_and_replace_conf(context, file)

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
    remove_txt = "{0}/dble/conf/{1}".format(context.cfg_dble['install_dir'], mapFile)
    text = str(context.text)
    cmd = "echo '{0}' > {1}".format(text, remove_txt)
    rc, sto, re = context.ssh_client.exec_command(cmd)
    assert_that(re, is_(''), "expect re is empty, but re is: {0}".format(re))

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

def upload_and_replace_conf(context, filename):
    local_file = get_abs_path(context, filename)
    remove_file = "{0}/dble/conf/{1}".format(context.cfg_dble['install_dir'],filename)
    context.ssh_sftp.sftp_put(remove_file,local_file)

def get_encrypt(context, string):
    cmd = "source /etc/profile && sh {0}/dble/bin/encrypt.sh {1}".format(context.cfg_dble['install_dir'], string)

    rc, sto, ste = context.ssh_client.exec_command(cmd)
    return sto.split('\n')[1]