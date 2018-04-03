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

def get_admin_conn(context):
    conn = DBUtil(context.dble_test_config['dble_host'], context.dble_test_config['manager_user'],
                  str(context.dble_test_config['manager_password']), "mytest", context.dble_test_config['manager_port'],
                  context)
    return conn

@Then('excute admin cmd "{adminsql}"')
@Then('excute admin cmd "{adminsql}" get the following output')
def step_impl(context, adminsql):
    conn = DBUtil(context.dble_test_config['dble_host'], context.dble_test_config['manager_user'],
                              str(context.dble_test_config['manager_password']), "mytest", context.dble_test_config['manager_port'], context)
    result, error = conn.query(adminsql)
    if error is not None:
        assert_that(context.text is not None, "expect success, but get err:{0}".format(error[1]))
        assert_that(str(error[1]), contains_string(context.text))
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

def new_dict(key,value):
    dict = " "
    if value == "":
        dict = " "
    elif value == "-":
        dict = "{0}:".format(key)
    else:
        dict = "{0}:{1}".format(key,value)

    return dict

def new_property(property):
    str = ""
    for i in len(property):
        str_sub =""
        if property[i] == "":
            str_sub = ""

def formatattr(attrs):
    lens = len(attrs)
    for i in range(lens):
        if attrs[lens - 1 - i].find(":") == -1:
            attrs[lens - 2 - i] = attrs[lens - 2 - i] + ',' + attrs[lens - 1 - i]
            del attrs[lens - 1 - i]
            # print(attrs)
    return attrs


@then('Check add {user_type} user success')
def check_user(context, user_type):
    text = json.loads(context.text)
    LOGGER.info("text: {0}, text: {1}".format(text, type(text)))
    user = text['user']
    password = text['password']
    if user_type == "manager":
        result = check_and_get_conn(context, user, password)
        assert_that(result, contains_string("succeed"))
    if user_type == "client":
        schemas = text['schemas'].split(',')
        for db in schemas:
            result = check_and_get_conn(context, user, password, db)
            assert_that(str(result), contains_string("succeed"))

def check_and_get_conn(context, user, passwd, db=None):
    result=""
    che = DBcheck(context.dble_test_config['dble_host'], user, passwd,context)
    if db is not None:
        result = che.conn_client(db)
    else:
        result = che.conn_manager()
    return result

@Then('Check the privilege of user "{user}"')
def check_privilege(context, user):
    text = json.loads(context.text)
    isReadOnly = isPrivilege = False
    schemas = []
    for item in text:
        if item.has_key('readOnly'):
            if item['value'] == "true":
                isReadOnly = True
        if item.has_key('privilege'):
            if item['value'] == "true":
                isPrivilege = True
        if item.has_key('schema'):
            schemas.append(item)
    for schema in schemas:
        db = schema['schema']
        db_dml = schema['dml']
        tables = schema['table']
        for table in tables:
            tabs = []

@Given('Delete the "{tablename}" table in the "{schemaname}" logical database in schema.xml')
def del_table(context, tablename, schemaname):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "schema.xml")
    cmd = "python {0} delTable --path={1} --schemaName={2} --name={3}".format(op_xmlfile,
                                                                                    filename,
                                                                                    schemaname,
                                                                                    tablename)
    os.popen(cmd)
    request = os.popen(cmd).read()
    assert_that(str(request), is_(""))
    upload_and_replace_conf(context, "schema.xml")
    check_not_has_value(context, "schema.xml", tablename)

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

@Given('Delete the child table in schema.xml')
def del_child_table(context):
    text = json.loads(context.text)
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "schema.xml")
    cmd = "python {0} delChildTable --path={1} --schemaName={2} --tableName={3} --childTables={4} --childName={5}".format(op_xmlfile,
                                                                                                         filename,
                                                                                                         text['schemaName'],
                                                                                                         text['tableName'],
                                                                                                         text['childTables'],
                                                                                                         text['childName'])
    os.popen(cmd)
    request = os.popen(cmd).read()
    assert_that(str(request), is_(""))
    upload_and_replace_conf(context, "schema.xml")
    check_not_has_value(context, "schema.xml", text['childName'])

@Given('Add a "{child_tables}" of the "{parent_table}" table in the "{schema_name}" logical database in schema.xml')
def add_child_table(context, child_tables, parent_table, schema_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "schema.xml")
    table = str(context.text).split(',')[0].split(':')[1]
    cmd = "python {0} createChildTable --path={1} --schemaName={2} --tableName={3} --childTables={4} --attributes={5}".format(op_xmlfile,
                                                                                                                              filename,
                                                                                                                              schema_name,
                                                                                                                              parent_table,
                                                                                                                              child_tables,
                                                                                                                              str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "schema.xml")
    LOGGER.info("table: {0}".format(table))
    check_has_value(context, "schema.xml", table)

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

@When('Execute "{cmd_sql}" on the managerment client and check system propertys')
def step_impl(context,cmd_sql):
    pass

@Then('Delete the schema "{schema}" in schema.xml')
def del_schema(context,schema):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "schema.xml")
    cmd = "python {0} delSchema --path={1} --name={2}".format(op_xmlfile, filename, schema)
    os.popen(cmd)
    upload_and_replace_conf(context, "schema.xml")
    check_not_has_value(context, "schema.xml", schema)

@Then('Execute "{sql}" on client and check {name} table type is "{type}"')
def check_table_type(context,sql,name,type):
    client_conn = get_dble_conn(context)
    context.logger.info("sqls:{0}".format(sql))
    result, error = client_conn.query(sql)
    flag = "failure"
    if type(result) == tuple:
        for i in range(len(result)):
            if result[i][0] == name and result[i][1] == type:
                flag = "succeed"
    assert_that(flag, has_string('succeed'))

@Then('Check reload success')
def check_reload(context):
    text = json.loads(context.text)

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