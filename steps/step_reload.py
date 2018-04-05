#coding= 'utf8'
import sys
import os
import logging
import json
import shlex

sys.path.append("..")
from behave import *
from hamcrest import *
from lib.DBUtil import *
from lib.XMLUtil import add_child_in_text, delete_child_node, get_xml_from_str, add_child_in_xml

LOGGER = logging.getLogger('steps.reload')

def check_has_value(context, filename, string):
    remove_file = "{0}/dble/conf/{1}".format(context.dble_test_config['dble_basepath'], filename)
    cmd = "cat {0} | grep '{1}' ".format(remove_file, string)
    rc, sto, re = context.ssh_client.exec_command(cmd)
    assert_that(re, is_(''))
    assert_that(sto, is_not(''))

def check_not_has_value(context, filename, string):
    remove_file = "{0}/dble/conf/{1}".format(context.dble_test_config['dble_basepath'], filename)
    cmd = "cat {0} | grep '{1}' ".format(remove_file, string)
    rc, sto, re = context.ssh_client.exec_command(cmd)
    assert_that(re, is_(''))
    assert_that(sto, is_(''))

def get_dble_conn(context):
    conn = DBUtil(context.dble_test_config['dble_host'], context.dble_test_config['client_user'],
                         context.dble_test_config['client_password'], "mytest", context.dble_test_config['client_port'],
                         context)
    return conn

def get_admin_conn(context, user="", passwd=""):
    if len(user.strip()) == 0:
        user = context.dble_test_config['manager_user']
    if len(passwd.strip()) == 0:
        passwd = str(context.dble_test_config['manager_password'])
    conn = DBUtil(context.dble_test_config['dble_host'], user, passwd, "mytest", context.dble_test_config['manager_port'],context)
    return conn

@Then('excute admin cmd "{adminsql}"')
@Then('excute admin cmd "{adminsql}" get the following output')
@Then('excute admin cmd "{adminsql}" with user "{user}" passwd "passwd"')
def step_impl(context, adminsql, user="", passwd=""):
    conn= get_admin_conn(context, user, passwd)
    result, error = conn.query(adminsql)
    if error is not None:
        assert_that(context.text is not None, "expect success, but get err:{0}".format(error[1]))
        assert_that(str(error[1]), contains_string(context.text.strip()))
    else:
        assert_that(context.text is None, 'expect "{0}" fail with err: {1}, but success'.format(adminsql, context.text))

    conn.close()

@Given('Edit a tableRule consisting of "{tablerule_name}","{column}","{function}" rule.xml')
def edit_tableRule(context, tablerule_name, column, function):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    columns = " "
    algorithms = " "

    if column == "-":
        columns = "--columns="
    elif column == " ":
        columns = " "
    else:
        columns = "--columns={0}".format(column)
    if function == "-":
        algorithms = "--algorithm="
    elif function == " ":
        algorithms = " "
    else:
        algorithms = "--algorithm={0}".format(function)
    cmd = "python {0} editTableRule --path={1} --name={2} {3} {4}".format(op_xmlfile,
                                                                          filename,
                                                                          tablerule_name,
                                                                          columns,
                                                                          algorithms)
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")

@Given('encrypt passwd and add xml segment to node with attribute "{kv_map_str}" in "{file}"')
def step_impl(context, kv_map_str, file):
    xmlSeg = get_xml_from_str(context.text)
    users = xmlSeg.findall('user')
    for user in users:
        need_encrypt = False
        for prop in user.children():
            if prop.get('usingDecrypt', None) == 1:
                need_encrypt = True
        if need_encrypt:
            for prop in user.children():
                if prop.get('password', None) is not None:
                    encrypt_string = "0:{0}:{1}".format(user.get('name'), prop.text)
                    encrypt_passwd = get_encrypt(context, encrypt_string)
                    prop.text = encrypt_passwd

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
    remove_txt = "{0}/dble/conf/{1}".format(context.dble_test_config['dble_basepath'], mapFile)
    text = str(context.text)
    cmd = "echo '{0}' > {1}".format(text, remove_txt)
    rc, sto, re = context.ssh_client.exec_command(cmd)
    assert_that(re, is_(''))

@When('Execute "{cmd}" on the managerment client and check system property with "{name}","{text}"')
def check_sys_property(context, cmd, name, text):
    manager_conn = get_admin_conn(context)
    flag = "failure"
    result, error = manager_conn.query(cmd)
    if type(result) == tuple:
        for i in range(len(result)):
            if result[i][0] == name and result[i][1] == text:
                flag = "succeed"
    assert_that(flag, has_string('succeed'))

# def get_opxml_and_localxml_path(context,filename):
#     op_file_path = "{0}/{1}".format(context.dble_test_config['dble_base_conf'], filename)
#     op_xml_path = "{0}".format(context.dble_test_config['opterate_xml_script'])
#     return op_file_path,op_xml_path
def get_abs_path(context, file):
    path = "{0}/{1}".format(context.dble_test_config['dble_base_conf'], file)
    return path

def upload_and_replace_conf(context, filename):
    local_file = get_abs_path(context, filename)
    remove_file = "{0}/dble/conf/{1}".format(context.dble_test_config['dble_basepath'],filename)
    context.ssh_sftp.sftp_put(remove_file,local_file)

@Then('Check add table success')
def check_add_table(context):
    text = json.loads(context.text)
    schema = table = type = None
    for item in text:
        if item['name'] == "schema":
            schema = item['value']
        if item['name'] == "table":
            table = item['value']
        if item['name'] == "type":
            type = item['value']

    if (not hasattr(context, "dble_conn")) or context.dble_conn is None:
        context.dble_conn = DBUtil(context.dble_test_config['dble_host'], context.dble_test_config['client_user'],
                              context.dble_test_config['client_password'], schema, context.dble_test_config['client_port'], context)
    sql = "create table if not exists {0}(id int)".format(table)
    res, err = context.dble_conn.query(sql)
    assert_that(err, is_(None))
    sql = "show full tables"
    res, err = context.dble_conn.query(sql)
    for row in res:
        if row[0] == "table":
            assert_that(row[1], contains_string(type))

    sql = "drop table {0}".format(table)
    res, err = context.dble_conn.query(sql)
    assert_that(err, is_(None))

def get_encrypt(context, string):
    cmd = "source /etc/profile && sh {0}/dble/bin/encrypt.sh {1}".format(context.dble_test_config['dble_basepath'], string)
    rc, sto, ste = context.ssh_client.exec_command(cmd)
    LOGGER.info("sto: {0}".format(sto.split('\n')[1]))
    return sto.split('\n')[1]