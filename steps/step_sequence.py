from lib.DBUtil import DBUtil

coding= 'utf8'
import json
import os
import logging
from behave import *
from lib.generate_util import *
from hamcrest import *
from pprint import pformat

LOGGER = logging.getLogger('steps.sequence')

@Given('Replace the existing configuration with the conf template directory')
def step_impl(context):
    osCmd = 'rm -rf {0} && cp -r {0}_bk {0}'.format(context.dble_test_config['dble_base_conf'])
    os.system(osCmd)

    cmd = 'rm -rf {0}/dble/conf_*'.format(context.dble_test_config['dble_basepath'])
    context.ssh_client.exec_command(cmd)
    cmd = 'cp -r {0}/dble/conf {0}/dble/conf_bk'.format(context.dble_test_config['dble_basepath'])
    context.ssh_client.exec_command(cmd)

    files = os.listdir(context.dble_test_config['dble_base_conf'])
    for file in files:
        local_file = "{0}/{1}".format(context.dble_test_config['dble_base_conf'], file)
        remove_file = "{0}/dble/conf/{1}".format(context.dble_test_config['dble_basepath'], file)
        context.ssh_sftp.sftp_put(remove_file, local_file)

    context.execute_steps(u'Given Restart dble by "{0}"'.format(context.dble_test_config['dble_host']))

@Given('Replace the existing configuration with the conf sql_cover directory')
def step_impl(context):
    cmd = 'rm -rf {0}/dble/conf_*'.format(context.dble_test_config['dble_basepath'])
    context.ssh_client.exec_command(cmd)
    cmd = 'cp -r {0}/dble/conf {0}/dble/conf_bk'.format(context.dble_test_config['dble_basepath'])
    context.ssh_client.exec_command(cmd)
    files = os.listdir(context.dble_test_config['dble_sql_conf'])
    for file in files:
        local_file = "{0}/{1}".format(context.dble_test_config['dble_sql_conf'], file)
        remove_file = "{0}/dble/conf/{1}".format(context.dble_test_config['dble_basepath'], file)
        context.ssh_sftp.sftp_put(remove_file, local_file)
    context.execute_steps(u'Given Restart dble by "{0}"'.format(context.dble_test_config['dble_host']))

@Then('Create "{auto_table}" table that uses a global sequence, and the auto_inc type is "{data_type}"')
def step_impl(context,auto_table,data_type):
    result = None
    errMes = None
    context.mycat_conn = DBUtil(context.mycat.ip, context.mycat.user, context.mycat.passwd, "mytest",
                                 context.mycat.port, context)
    context.mycat_conn.dropTable(auto_table, context)
    sql = "show tables"
    result,errMes = context.mycat_conn.query(sql)
    assert_that(str(result),is_not(auto_table))
    sql = "create table " + auto_table + "( id " + data_type + " primary key auto_increment, name varchar(20))"
    context.mycat_conn.query(sql)

    sql = "show tables"
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(result),contains_string(auto_table))

@Then('Check if the global sequence is "{seq_type}" and table "{auto_table}" can be used normally')
def step_impl(context,seq_type,auto_table):
    result = None
    errMes = None
    gen = generate()
    name = gen.rand_string(20)
    sql = "insert into {0} values ( '{1}')".format(auto_table, name)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(errMes, is_(None))

    server_path = "{0}{1}/conf/server.xml".format(context.mycat.install_path, context.mycat.item)
    cmd = "cat {0} | grep -e 'sequnceHandlerType'".format(server_path,seq_type)
    result = context.ssh.exec_command(cmd)
    assert_that(str(result),contains_string(str(seq_type)))

@Then('Testing the auto_inc data type constraint:"{seq_type}","{auto_table}","{auto_col}","{data_type}"')
def step_impl(context, seq_type, auto_table, auto_col, data_type):
    text = json.loads(context.text)
    context.mycat_conn = DBUtil(context.mycat.ip, context.mycat.user, context.mycat.passwd, "mytest",
                                 context.mycat.port, context)
    context.mycat_conn.dropTable(auto_table, context)
    sql = "show tables"
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(result), is_not(auto_table))

    sql = "create table {0}({1} {2} primary key auto_increment, name varchar(10))".format(str(auto_table), auto_col, data_type)
    context.mycat_conn.query(sql)

    sql = "show tables"
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(result), contains_string(auto_table))

    if seq_type == "2" and data_type == "int":
        gen = generate()
        name = gen.rand_string(20)
        sql = "insert into {0} values ( '{1}')".format(auto_table, name)
        result, errMes = context.mycat_conn.query(sql)
        assert_that(str(errMes), contains_string("Out of range value for column"))

@Then('Testing display specified is not supported for auto_inc columns:"{seq_type}","{auto_table}","{auto_col}"')
def step_impl(context, seq_type, auto_table, auto_col):
    result = None
    errMes = None
    data_type = "int"
    if seq_type == "2" or seq_type == "3":
        data_type = "bigint"
    context.mycat_conn = DBUtil(context.mycat.ip, context.mycat.user, context.mycat.passwd, "mytest",
                                 context.mycat.port, context)
    context.mycat_conn.dropTable(auto_table, context)
    sql = "show tables"
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(result), is_not(auto_table))

    sql = "create table {0}({1} {2} primary key auto_increment, name varchar(20))".format(auto_table, auto_col,
                                                                                          data_type)
    context.mycat_conn.query(sql)

    sql = "show tables"
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(result), contains_string(auto_table))

    gen = generate()
    name = gen.rand_string(20)
    sql = "insert into {0} ({1}, name) values (1,'{2}')".format(auto_table, auto_col, name)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(errMes), contains_string("In insert Syntax, you can't set value for Autoincrement column!"))

    sql = "insert into {0} set {1} = 1, name = '{2}'".format(auto_table, auto_col, name)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(errMes), contains_string("In insert Syntax, you can't set value for Autoincrement column!"))

    sql = "insert into {0} set name = '{1}'".format(auto_table, name)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(errMes, is_(None))

@Then('Testing No auto_inc keys are specified when building a table:"{seq_type}","{auto_table}","{auto_col}"')
def step_impl(context, seq_type, auto_table, auto_col):
    result = None
    errMes = None
    data_type = "int"
    if seq_type == "2" or seq_type == "3":
        data_type = "bigint"
    context.mycat_conn = DBUtil(context.mycat.ip, context.mycat.user, context.mycat.passwd, "mytest",
                                 context.mycat.port, context)
    context.mycat_conn.dropTable(auto_table, context)
    sql = "show tables"
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(result), is_not(auto_table))
    sql = "create table {0}({1} {2}, name varchar(20))".format(auto_table, auto_col, data_type)
    context.mycat_conn.query(sql)
    sql = "show tables"
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(result), contains_string(auto_table))

    gen = generate()
    name = gen.rand_string(20)
    sql = "insert into {0} values ('{1}')".format(auto_table, name)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(errMes), contains_string("please make sure your table structure has primaryKey"))
    sql = "insert into {0} (name) values ('{1}')".format(auto_table, name)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(errMes, is_(None))

    context.mycat_conn.dropTable(auto_table, context)
    sql = "create table {0}({1} {2} auto_increment, name varchar(20), primary key ({1}))".format(auto_table, auto_col, data_type)
    context.mycat_conn.query(sql)

    gen = generate()
    name = gen.rand_string(20)
    sql = "insert into {0} values ('{1}')".format(auto_table, name)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(errMes, is_(None))
    sql = "insert into {0} (name) values ('{1}')".format(auto_table, name)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(errMes, is_(None))
    sql = "insert into {0} set name = '{1}' ".format(auto_table, name)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(errMes, is_(None))

@Then('Testing Global Sequence Uniqueness and uniform partch :"{seq_type}","{auto_table}","{auto_col}","{rows}"')
def step_impl(context, seq_type, auto_table, auto_col, rows):
    result = None
    errMes = None
    data_type = "int"
    if seq_type == "2" or seq_type == "3":
        data_type = "bigint"
    context.mycat_conn = DBUtil(context.mycat.ip, context.mycat.user, context.mycat.passwd, "mytest",
                                 context.mycat.port, context)
    context.mycat_conn.dropTable(auto_table, context)
    sql = "show tables"
    result, errMes = context.mycat_conn.query(sql)
    assert_that(str(result), is_not(auto_table))

    sql = "create table {0}({1} {2} primary key auto_increment, name varchar(20))".format(auto_table, auto_col,
                                                                                          data_type)
    context.mycat_conn.query(sql)
    gen = generate()
    sql = "insert into {0} values ('{1}'), ('{1}'), ('{1}')".format(auto_table, gen.rand_string(20))
    context.mycat_conn.query(sql)
    sql = "select count(*) from {0} having count(*) > 1 group by {1};".format(auto_table, auto_col)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(result, is_(()))

    for i in range(int(rows)):
        sql = "insert into {0} values ('{1}')".format(auto_table, gen.rand_string(20))
        context.mycat_conn.query(sql)
    sql = "select count(*) from {0} having count(*) > 1 group by {1};".format(auto_table, auto_col)
    result, errMes = context.mycat_conn.query(sql)
    assert_that(result, is_(()))

    sql = "explain select * from {0}".format(auto_table)
    result, errMes = context.mycat_conn.query(sql)
    if type(result) == tuple:
        for i in range(len(result)):
            sql = "/*!{0}:dataNode={1}*/select count(*) from {2}".format(context.mycat.item, result[i][0], auto_table)
            res, err = context.mycat_conn.query(sql)
            assert_that(int(res[0][0]), greater_than_or_equal_to(200))

@Then('Testing the global sequence can used in table')
def step_impl(context):
    text = json.loads(context.text)
    LOGGER.info("text: {0}, text: {1}".format(text, type(text)))
    key_value = {}
    for item in text:
        key_value[item['name']] = item['value']
    LOGGER.info("sequnceHandlerType: {0}".format(key_value['sequnceHanderType']))
    server_path = "{0}/dble/conf/server.xml".format(context.dble_test_config['dble_basepath'])
    cmd = "cat {0} | grep -e 'sequnceHandlerType'".format(server_path)
    rc, sto, ste = context.ssh_client.exec_command(cmd)
    assert_that(str(sto), contains_string(str(key_value['sequnceHanderType'])))
    if (not hasattr(context, "dble_conn")) or context.dble_conn is None:
        context.dble_conn = DBUtil(context.dble_test_config['dble_host'], context.dble_test_config['client_user'],
           context.dble_test_config['client_password'], "mytest", context.dble_test_config['client_port'], context)
    context.dble_conn.dropTable(key_value['table'], context)
    data_type = " "
    if key_value['sequnceHanderType'] == "2" or key_value['sequnceHanderType'] == "3":
        data_type = "bigint"
    sql = "create table {0}({1} {2} primary key auto_increment, name varchar(20))".format(key_value['table'], key_value['auto_col'], data_type)
    context.dble_conn.query(sql)
    gen = generate()
    name = gen.rand_string(20)
    sql = "insert into {0} values ('{1}')".format(key_value['table'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(errMes, is_(None))
    sql = "select count(*) from {0}".format(key_value['table'])
    result, errMes = context.dble_conn.query(sql)
    assert_that(int(result[0][0]), equal_to(1))

    #test display specifird is not supported for auto_inc cplumns
    sql = "insert into {0} ({1}, name) values (1,'{2}')".format(key_value['table'], key_value['auto_col'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(str(errMes), contains_string("In insert Syntax, you can't set value for Autoincrement column!"))
    sql = "insert into {0} set {1} = 1, name = '{2}'".format(key_value['table'], key_value['auto_col'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(str(errMes), contains_string("In insert Syntax, you can't set value for Autoincrement column!"))
    sql = "insert into {0} set name = '{1}'".format(key_value['table'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(errMes, is_(None))

    #test No auto_inc keys are specified when building a table:
    context.dble_conn.dropTable(key_value['table'], context)
    sql = "create table {0}({1} {2}, name varchar(20))".format(key_value['table'], key_value['auto_col'], data_type)
    context.dble_conn.query(sql)
    sql = "insert into {0} values ('{1}')".format(key_value['table'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(str(errMes), contains_string("please make sure your table structure has primaryKey"))
    sql = "insert into {0} (name) values ('{1}')".format(key_value['table'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(errMes, is_(None))
    context.dble_conn.dropTable(key_value['table'], context)
    sql = "create table {0}({1} {2} auto_increment, name varchar(20), primary key ({1}))".format(key_value['table'], key_value['auto_col'],
                                                                                                 data_type)
    context.dble_conn.query(sql)
    sql = "insert into {0} values ('{1}')".format(key_value['table'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(errMes, is_(None))
    sql = "insert into {0} (name) values ('{1}')".format(key_value['table'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(errMes, is_(None))
    sql = "insert into {0} set name = '{1}' ".format(key_value['table'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(errMes, is_(None))

    #test the auto_inc data type constraint
    context.dble_conn.dropTable(key_value['table'], context)
    if key_value['sequnceHanderType'] == "2" or key_value['sequnceHanderType'] == "3":
        data_type = "int"
    sql = "create table {0}({1} {2} primary key auto_increment, name varchar(20))".format(key_value['table'],
                                                                                          key_value['auto_col'],
                                                                                          data_type)
    context.dble_conn.query(sql)
    gen = generate()
    name = gen.rand_string(20)
    sql = "insert into {0} values ( '{1}')".format(key_value['table'], name)
    result, errMes = context.dble_conn.query(sql)
    assert_that(str(errMes), contains_string("Out of range value for column"))

    #test Global Sequence Uniqueness and uniform partch
    context.dble_conn.dropTable(key_value['table'], context)
    sql = "create table {0}({1} {2} primary key auto_increment, name varchar(20))".format(key_value['table'], key_value['auto_col'],
                                                                                          data_type)
    context.dble_conn.query(sql)
    gen = generate()
    sql = "insert into {0} values ('{1}'), ('{1}'), ('{1}')".format(key_value['table'], gen.rand_string(20))
    context.dble_conn.query(sql)
    sql = "select count(*) from {0} having count(*) > 1 group by {1};".format(key_value['table'], key_value['auto_col'])
    result, errMes = context.dble_conn.query(sql)
    assert_that(result, is_(()))
    for i in range(int(key_value['count'])):
        sql = "insert into {0} values ('{1}')".format(key_value['table'], gen.rand_string(20))
        context.dble_conn.execute_sql(sql)
    sql = "select count(*) from {0} having count(*) > 1 group by {1};".format(key_value['table'], key_value['auto_col'])
    result, errMes = context.dble_conn.query(sql)
    assert_that(result, is_(()))

    sql = "explain select * from {0}".format(key_value['table'])
    result, errMes = context.dble_conn.query(sql)
    if type(result) == tuple:
        for i in range(len(result)):
            sql = "/*!dble:dataNode={0}*/select count(*) from {1}".format(result[i][0], key_value['table'])
            res, err = context.dble_conn.query(sql)
            assert_that(int(res[0][0]), greater_than_or_equal_to(200))

@Given('Add self-added table-node correspondence relationship:"{seq_conf_file}"')
def step_impl(context, seq_conf_file):
    LOGGER.info("Add self-added table-node correspondence relationship:{0}".format(pformat(seq_conf_file)))
    seq_conf_path = "{0}{1}/conf/{2}".format(context.mycat.install_path, context.mycat.item, seq_conf_file)

    cmd = "cat {0} | grep '`mytest`.`test_auto`=dn1' ".format(seq_conf_path)
    result = context.ssh.exec_command(cmd)
    if result != context.text:
        cmd = "echo '{0}'>> {1}".format(context.text, seq_conf_path)
        context.ssh.exec_command(cmd)
        cmd = "cat {0} | grep '`mytest`.`test_auto`=dn1' ".format(seq_conf_path)
        result = context.ssh.exec_command(cmd)
        assert_that(str(result), contains_string(context.text))

    dnode = ["dn1", "dn2", "dn3", "dn4", "dn5"]
    for node in dnode:
        if str(context.text).find(node):
            dnode_conn = create_dnode_conn(context, node)
            sql = "source {0}{1}/conf/"

def create_dnode_conn(context, dnode):
    cur_dnode = getattr(context, dnode)
    conn = DBUtil(cur_dnode.mysql_ip, cur_dnode.mysql_user, cur_dnode.mysql_passwd, cur_dnode.mysql_db,
                               cur_dnode.mysql_port, context)

    return conn
