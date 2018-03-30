#coding= 'utf8'
import sys
import os
import logging
import json
sys.path.append("..")
from behave import *
from hamcrest import *
from lib.DBUtil import *
from lib.XMLUtil import add_child_node

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

@When('Log in {clientName} client')
def create_conn_manager_or_client(context, clientName):
    if clientName == "management":
        manager_conn = DBUtil(context.dble_test_config['dble_host'], context.dble_test_config['manager_user'],
                              str(context.dble_test_config['manager_password']), "mytest", context.dble_test_config['manager_port'], context)
        return manager_conn
    if clientName == "client":
        client_conn = DBUtil(context.dble_test_config['dble_host'], context.dble_test_config['client_user'],
                              context.dble_test_config['client_password'], "mytest", context.dble_test_config['client_port'], context)
        return client_conn

@When('Execute reload @@config_all anomalous')
def execute_reload_anomalous(context):
    context.manager_conn = create_conn_manager_or_client(context, "management")
    sql = "reload @@config_all"
    result, error = context.manager_conn.query(sql)
    context.manager_conn.close()
    assert_that(str(error), contains_string("Reload config failure"))

@When('Execute reload @@config_all')
def execute_reload(context):
    context.manager_conn = create_conn_manager_or_client(context, "management")
    sql = "reload @@config_all"
    result, error = context.manager_conn.query(sql)
    context.manager_conn.close()
    assert_that(str(error), has_string('None'))

@When('Execute sql in manager')
def execute_manager_sql(context,):
    context.manager_conn = create_conn_manager_or_client(context, "management")
    sql = str(context.text)
    result, error = context.manager_conn.query(sql)
    context.manager_conn.close()
    assert_that(str(error), has_string('None'))

@Given('Add a tableRule consisting of "{tablerule_name}","{column}","{function}" in rule.xml')
def add_tableRule(context, tablerule_name, column, function):
    context.execute_steps(u'Given Drop a tableRule "{0}" in rule.xml'.format(tablerule_name))
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} createTableRule --path={1} --name={2} --columns={3} --algorithm={4}".format(op_xmlfile,
                                                                                                  filename,
                                                                                                  tablerule_name,
                                                                                                  column,
                                                                                                  function)
    os.popen(cmd)
    cmd = "cat {0} | grep '{1}'".format(filename, tablerule_name)
    res = os.popen(cmd).read()
    assert_that(res, is_not(''))
    upload_and_replace_conf(context, "rule.xml")
    check_has_value(context, "rule.xml", tablerule_name)

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

@Given('add xml segment in "{file}" to "{parentTag}"')
def step_impl(context, file, parentTag):
    get_abs_path(context, file)
    add_child_node(file, parentTag, context.text)
    upload_and_replace_conf(context, file)

@Given('Edit a "{rule_name}" hash function in rule.xml')
def edit_hash_function(context, rule_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} editFunction --path={1} --name={2} --propertys={3}".format(op_xmlfile,
                                                                                 filename,
                                                                                 rule_name,
                                                                                 str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")
    check_has_value(context, "rule.xml", rule_name)

@Given('Drop a "{rule_name}" function in rule.xml')
def drop_hash_function(context, rule_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} delFunction --path={1} --name={2} ".format(op_xmlfile,
                                                                  filename,
                                                                  rule_name)
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")
    check_not_has_value(context, "rule.xml", rule_name)

@Given('Add a "{rule_name}" StringHash function in rule.xml')
def add_stringhash_function(context, rule_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} createFunction --path={1} --class=StringHash --name={2} --propertys={3}".format(op_xmlfile,
                                                                                                filename,
                                                                                                rule_name,
                                                                                                str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")
    check_has_value(context, "rule.xml", rule_name)

@Given('Add a "{rule_name}" NumberRange function in rule.xml')
def add_numberrange_function(context, rule_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} createFunction --path={1} --class=NumberRange --name={2} --propertys={3}".format(op_xmlfile,
                                                                                                      filename,
                                                                                                      rule_name,
                                                                                                      str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")
    check_has_value(context, "rule.xml", rule_name)

@When('Add some data in "{mapFile}"')
def add_file(context,mapFile):
    remove_txt = "{0}/dble/conf/{1}".format(context.dble_test_config['dble_basepath'], mapFile)
    text = str(context.text)
    cmd = "echo '{0}' > {1}".format(text, remove_txt)
    rc, sto, re = context.ssh_client.exec_command(cmd)
    assert_that(re, is_(''))
    cmd = "dos2unix {0}".format(remove_txt)
    rc, sto, re = context.ssh_client.exec_command(cmd)
    assert_that(re, contains_string("UNIX format"))
    LOGGER.info("text: {0}".format(text.split('\n')))
    check_has_value(context, mapFile, text.split('\n')[0].strip('\r'))

@Given('Edit a "{rule_name}" NumberRange function in rule.xml')
def edit_numberrange_function(context, rule_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} editFunction --path={1} --class=NumberRange --name={2} --propertys={3}".format(op_xmlfile,
                                                                                                       filename,
                                                                                                       rule_name,
                                                                                                       str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")
    check_has_value(context, "rule.xml", rule_name)

@Given('Add a "{rule_name}" Enum function in rule.xml')
def add_enum_function(context, rule_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} createFunction --path={1} --class=Enum --name={2} --propertys={3}".format(op_xmlfile,
                                                                                                filename,
                                                                                                rule_name,
                                                                                                str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")
    check_has_value(context, "rule.xml", rule_name)

@Given('Add a "{rule_name}" Date function in rule.xml')
def add_date_function(context, rule_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} createFunction --path={1} --class=Date --name={2} --propertys={3}".format(op_xmlfile,
                                                                                                filename,
                                                                                                rule_name,
                                                                                                str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")
    check_has_value(context, "rule.xml", rule_name)

@Given('Edit a "{rule_name}" Date function in rule.xml')
def edit_date_function(context, rule_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} editFunction --path={1} --class=Date --name={2} --propertys={3}".format(op_xmlfile,
                                                                                                filename,
                                                                                                rule_name,
                                                                                                str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")
    check_has_value(context, "rule.xml", rule_name)

@Given('Add a "{rule_name}" Partition function in rule.xml')
def add_partition_function(context, rule_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "rule.xml")
    cmd = "python {0} createFunction --path={1} --class=PatternRange --name={2} --propertys={3}".format(op_xmlfile,
                                                                                                    filename,
                                                                                                    rule_name,
                                                                                                    str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "rule.xml")
    check_has_value(context, "rule.xml", rule_name)

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

@Given('Add a user consisting of "{user}" in server.xml')
def add_user(context, user):
    LOGGER.info("context.text: {0}, context.text: {1}".format(context.text, type(context.text)))
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "server.xml")
    cmd = ""
    if str(context.text).find('"usingDecrypt":"1"') == -1:
        cmd = "python {0} createUser --path={1} --name={2} --propertys={3}".format(op_xmlfile,
                                                                               filename,
                                                                               user,
                                                                               str(context.text))
    else:
        LOGGER.info("context.text.strip(','): {0}".format(str(context.text).strip(',')))
        password = str(context.text).split(',')[0].split(':')[1]
        encrypt_string = "0:{0}:{1}".format(user, password)
        encrypt_passwd = get_encrypt(context, encrypt_string)
        LOGGER.info("encrypt_passwd: {0}".format(encrypt_passwd))
        property = str(context.text).replace(password, encrypt_passwd)
        cmd = "python {0} createUser --path={1} --name={2} --propertys={3}".format(op_xmlfile,
                                                                                   filename,
                                                                                   user,
                                                                                   property)
    os.popen(cmd)
    upload_and_replace_conf(context, "server.xml")
    check_has_value(context, "server.xml", user)

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

@Then('Delete the user "{user}"')
def del_user(context, user):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "server.xml")
    cmd = "python {0} delUser --path={1} --name={2}".format(op_xmlfile,
                                                            filename,
                                                            user)
    os.popen(cmd)
    upload_and_replace_conf(context, "server.xml")
    check_not_has_value(context, "server.xml", user)

@When('generate decrypt password with "{type}","{user}","{passwd}"')
def gen_decrypt_passwd(context,type,user,passwd):
    jar_path = "{0}/lib"

@Given('Add a privilege of "{user}" user in server.xml')
def add_privilege(context, user):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "server.xml")
    privilege = schemas = tables = " "
    text = context.text.split('\n')
    for line in text:
        LOGGER.info("line: {0},{1},{2}".format(line, type(line.split('=')[0]), line.split('=')[1]))
        if "privileges" in line:
            privilege = line.split('=')[1]
        if "schemas" in line:
            schemas = line.split('=')[1]
        if "tables" in line:
            tables = line.split('=')[1]
    LOGGER.info("privilege: {0},schemas: {1},tables: {2}".format(privilege[1:-1], schemas[1:-1], tables[1:-1]))
    cmd = "python {0} createUserPrivilege --path={1} --privileges={2} --schemas={3} --tables={4}".format(op_xmlfile,
                                                                                                        filename,
                                                                                                        privilege,
                                                                                                        schemas,
                                                                                                        tables)
    os.popen(cmd)
    upload_and_replace_conf(context, "server.xml")

@Then('Delete the privilege of "{user}" user in server.xml')
def del_privilege(context, user):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "server.xml")
    cmd = "python {0} delUserPrivileges --path={1} --name={2}".format(op_xmlfile, filename, user)
    os.popen(cmd)
    upload_and_replace_conf(context, "server.xml")

@Given('Add a Firewall in schema.xml')
def add_firewall(context):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "server.xml")
    hosts = blacklist = propertys = values = " "
    text = context.text.split('\n')
    for line in text:
        LOGGER.info("line: {0},{1},{2}".format(line, type(line.split('=')[0]), line.split('=')[1]))
        if "hosts" in line:
            hosts = line.split('=')[1]
        if "blacklist" in line:
            blacklist = line.split('=')[1]
        if "propertys" in line:
            propertys = line.split('=')[1]
        if "values" in line:
            values = line.split('=')[1]
    LOGGER.info("hosts: {0},blacklist: {1},propertys: {2},values: {3}".format(hosts, blacklist, propertys, values))
    cmd = "python {0} createFirewall --path={1} --hosts={2} --blacklist={3} --propertys={4} --values={5}".format(op_xmlfile,
                                                                                                                filename,
                                                                                                                hosts,
                                                                                                                blacklist,
                                                                                                                propertys,
                                                                                                                 values)
    os.popen(cmd)
    upload_and_replace_conf(context, "server.xml")
    check_has_value(context, "server.xml", "firewall")

@Then('Delete the Firewall in schema.xml')
def del_firewall(context):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "server.xml")
    cmd = "python {0} delFirewall --path={1}".format(op_xmlfile, filename)
    os.popen(cmd)
    upload_and_replace_conf(context, "server.xml")
    check_not_has_value(context, "server.xml", "firewall")

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

@Given('Add a "{schema}" schema in schema.xml')
def add_schema(context, schema):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "schema.xml")
    cmd = " "
    if not hasattr(context, "text"):
        cmd = "python {0} createSchema --path={1} --name={2}".format(op_xmlfile, filename, schema)
    else:
        cmd = "python {0} createSchema --path={1} --name={2} --attributes={3}".format(op_xmlfile, filename, schema, str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "schema.xml")
    check_has_value(context, "schema.xml", schema)

@Then('Delete the "{schema}" schema in schema.xml')
def del_schema(context, schema):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "schema.xml")
    cmd = "python {0} delSchema --path={1} --name={2}".format(op_xmlfile, filename, schema)
    os.popen(cmd)
    upload_and_replace_conf(context, "schema.xml")
    check_not_has_value(context, "schema.xml", schema)

@given('Add a table consisting of "{schema}" in schema.xml')
def add_table(context, schema):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "schema.xml")
    table = str(context.text).split(',')[0].split(':')[1]
    context.execute_steps(u'Given Delete the "{0}" table in the "{1}" logical database in schema.xml'.format(table, schema))
    cmd = "python {0} createTable --path={1} --schemaName={2} --attributes={3}".format(op_xmlfile,
                                                                                       filename,
                                                                                       schema,
                                                                                       str(context.text))
    os.popen(cmd)
    upload_and_replace_conf(context, "schema.xml")
    LOGGER.info("table: {0}".format(table))
    check_has_value(context, "schema.xml", table)

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

@Given('Add a system property consisting of "{name}","{text}" in server.xml')
def add_sys_property(context, name, text):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "server.xml")
    cmd = "python {0} createProperty --path={1} --name={2} --text={3}".format(op_xmlfile, filename, name, text)
    os.popen(cmd)
    upload_and_replace_conf(context, "server.xml")
    check_has_value(context, "server.xml", name)

@When('Execute "{cmd}" on the managerment client and check system property with "{name}","{text}"')
def check_sys_property(context, cmd, name, text):
    manager_conn = create_conn_manager_or_client(context,"management")
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

@Given('Delete the dataNode "{datanode_name}" in schema.xml')
def del_dataNode(context, datanode_name):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "schema.xml")
    cmd = "python {0} delDataNode --path={1} --name={2}".format(op_xmlfile, filename, datanode_name)
    os.popen(cmd)
    request = os.popen(cmd).read()
    assert_that(str(request), is_(""))
    upload_and_replace_conf(context, "schema.xml")
    check_not_has_value(context, "schema.xml", datanode_name)

@Given('Add the dataNode in schema.xml')
def add_dataNode(context):
    text = json.loads(context.text)
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "schema.xml")
    cmd = "python {0} createDataNode --path={1} --name={2} --dataHost={3} --database={4}".format(op_xmlfile,
                                                                                                 filename,
                                                                                                 str(text['name']),
                                                                                                 str(text['dataHost']),
                                                                                                 str(text['database']))
    os.popen(cmd)
    upload_and_replace_conf(context, "schema.xml")
    check_has_value(context, "schema.xml", str(text['name']))

# def get_opxml_and_localxml_path(context,filename):
#     op_file_path = "{0}/{1}".format(context.dble_test_config['dble_base_conf'], filename)
#     op_xml_path = "{0}".format(context.dble_test_config['opterate_xml_script'])
#     return op_file_path,op_xml_path
def get_abs_path(context, file):
    path = "{0}/{1}".format(context.dble_test_config['dble_base_conf'], file)
    return path

def upload_and_replace_conf(context, filename):
    local_file = "{0}/{1}".format(context.dble_test_config['dble_base_conf'],filename)
    remove_file = "{0}/dble/conf/{1}".format(context.dble_test_config['dble_basepath'],filename)
    context.ssh_sftp.sftp_put(remove_file,local_file)

@Given('Edit a system property consisting of "{name}","{text}" in server.xml')
def edit_sys_property(context, name, text):
    filename,op_xmlfile = get_opxml_and_localxml_path(context,"server.xml")
    cmd = "python {0} editOrDelProperty --path={1} --name={2} --text={3}".format(op_xmlfile, filename, name, text)
    os.popen(cmd)
    upload_and_replace_conf(context,"server.xml")
    check_has_value(context, "server.xml", name)
    check_has_value(context, "server.xml", text)

@Given('Add some system propertys in server.xml')
def step_impl(context):
    filename, op_xmlfile = get_opxml_and_localxml_path(context, "server.xml")
    names = []
    texts = []
    for row in context.table:
        names.append(row['name'])
        texts.append(row['text'])
    for i in range(len(names)):
        cmd = "python {0} createProperty --path={1} --name={2} --text={3}".format(op_xmlfile,filename,names[i],texts[i])
        os.popen(cmd)
    upload_and_replace_conf(context, "server.xml")

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
    client_conn = create_conn_manager_or_client(context, "client")
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