import sys
import logging
import json
sys.path.append("..")
from behave import *
from lib.QueryDB import *
from hamcrest import *
from step_reload import create_conn_manager_or_client
from lib.generate_util import *

LOGGER = logging.getLogger('steps.function')

@then('Test the data types supported by the sharding column in "{sql_name}"')
def test_data_type(context, sql_name):
    LOGGER.info("test all data types")
    sql_path = "function/{0}".format(sql_name)
    context.execute_steps(u'Then execute sql in "{0}" to check read-write-split work fine and log dest slave'.format(sql_path))
    if (not hasattr(context, "dble_conn")) or context.dble_conn is None:
        context.dble_conn = QueryDB(context.dble_test_config['dble_host'], context.dble_test_config['client_user'],
       context.dble_test_config['client_password'], "mytest", context.dble_test_config['client_port'], context)

@Then('Create table "{table}" and check sharding')
def test_sharding(context, table):
    text = json.loads(context.text)
    if (not hasattr(context, "dble_conn")) or context.dble_conn is None:
        context.dble_conn = QueryDB(context.dble_test_config['dble_host'], context.dble_test_config['client_user'],
       context.dble_test_config['client_password'], "mytest", context.dble_test_config['client_port'], context)
    context.dble_conn.dropTable(table, context)
    sql = ""
    key_value = {}
    for item in text:
        key_value[item['name']] = item['value']
    if key_value['type'] == "string":
        sql = "create table {0}({1} varchar(10))".format(table, key_value['key'])
    elif key_value['type'] == "number":
        sql = "create table {0}({1} int)".format(table, key_value['key'])
    else:
        sql = "create table {0}({1} date)".format(table, key_value['key'])
    context.dble_conn.execute_sql(sql)
    ins_values = key_value['normal_value'].split(',')
    for value in ins_values:
        if key_value['type'] != "number":
            sql = "insert into {0} value ('{1}')".format(table, str(value))
        else:
            sql = "insert into {0} value ({1})".format(table, str(value))
        result, errMes = context.dble_conn.execute_sql(sql)
        assert_that(errMes, is_(None))
    nodes = []
    for key in key_value.keys():
        if str(key).startswith('dn'):
            nodes.append(key)
    nodes_conn = create_node_conn(context)
    sql = "select * from {0}".format(table)
    for node in nodes:
        res, err = nodes_conn[str(node)].execute_sql(sql)
        LOGGER.info("result: {0}".format(str(res)))
        assert_that(err, is_(None))
        if type(res) == tuple:
            assert_that(key_value[node], contains_string(str(res[0][0])))
        else:
            assert_that(False, "execute sql failure !!!")
    if "abnormal_value" in key_value.keys():
        for value in key_value['abnormal_value'].split(','):
            if key_value['type'] != "number":
                sql = "insert into {0} value ('{1}')".format(table, str(value))
            else:
                sql = "insert into {0} value ({1})".format(table, str(value))
            result, errMes = context.dble_conn.execute_sql(sql)
            assert_that(str(errMes), contains_string("can't find any valid data node"))
    if "error_type_value" in key_value.keys():
        for value in key_value['error_type_value'].split(','):
            if key_value['type'] != "number":
                sql = "insert into {0} value ('{1}')".format(table, str(value))

            else:
                context.dble_conn.dropTable(table, context)
                sql = "create table {0}({1} varchar(10))".format(table, key_value['key'])
                context.dble_conn.execute_sql(sql)
                sql = "insert into {0} value ('{1}')".format(table, str(value))
            result, errMes = context.dble_conn.execute_sql(sql)
            assert_that(str(errMes), contains_string("Please check if the format satisfied"))
    context.dble_conn.dropTable(table, context)

def create_node_conn(context):
    if (not hasattr(context, "manager_conn")) or context.manager_conn is None:
        context.manager_conn = create_conn_manager_or_client(context, "management")
    sql = "show @@datanode"
    result, error = context.manager_conn.query(sql)
    datanode = {}
    if type(result) == tuple:
        for i in range(len(result)):

            datanode[result[i][0]] = result[i][1]
    port = 3306
    node_conn = {}
    for node in datanode.keys():
        user = context.dble_test_config['mysql_user']
        password = context.dble_test_config['mysql_password']
        host = datanode[node].split('/')[0]
        db = datanode[node].split('/')[1]
        LOGGER.info("{0} create, host:{1}, db:{2}".format(node, host, db))
        conn = QueryDB(host, user, password, db, port, context)
        node_conn[node] = conn
    return node_conn

@Then('Test and check reload config failure')
def test_reload_failure(context):
    if (not hasattr(context, "manager_conn")) or context.manager_conn is None:
        context.manager_conn = create_conn_manager_or_client(context, "management")
    sql = "reload @@config_all"
    result, error = context.manager_conn.query(sql)
    assert_that(str(error[1]), contains_string(context.text))

@Then('Test the use of limit by the sharding column')
def test_use_limit(context):
    text = json.loads(context.text)
    key_value = {}
    for item in text:
        key_value[item['name']] = item['value']
    if (not hasattr(context, "dble_conn")) or context.dble_conn is None:
        context.dble_conn = QueryDB(context.dble_test_config['dble_host'], context.dble_test_config['client_user'],
       context.dble_test_config['client_password'], "mytest", context.dble_test_config['client_port'], context)
    context.dble_conn.dropTable(key_value['table'], context)
    gen = generate()
    name = gen.rand_string(10)
    sql = "create table {0}({1} int, data varchar(10))".format(key_value['table'], key_value['key'])
    context.dble_conn.createTable(sql)
    sql = "alter table {0} drop column {1}".format(key_value['table'], key_value['key'])
    result, errMes = context.dble_conn.execute_sql(sql)
    assert_that(str(errMes[1]), contains_string("The columns may be sharding keys or ER keys, are not allowed to alter sql"))
    sql = "update {0} set {1} = 1".format(key_value['table'], key_value['key'])
    result, errMes = context.dble_conn.execute_sql(sql)
    assert_that(str(errMes[1]), contains_string("Sharding column can't be updated"))
    sql = "insert into {0} (data) values ('{1}')".format(key_value['table'], name)
    result, errMes = context.dble_conn.execute_sql(sql)
    assert_that(str(errMes[1]), contains_string("bad insert sql, sharding column/joinKey:ID not provided"))
    sql = "insert into {0} values (1+1, '{1}')".format(key_value['table'], name)
    result, errMes = context.dble_conn.execute_sql(sql)
    assert_that(str(errMes[1]), contains_string("Not Supported of Sharding Value EXPR"))
    context.dble_conn.dropTable(key_value['table'], context)
    sql = "create table {0}(data varchar(10))".format(key_value['table'])
    context.dble_conn.execute_sql(sql)
    sql = "insert into {0} values ('{1}')".format(key_value['table'], name)
    result, errMes = context.dble_conn.execute_sql(sql)
    assert_that(str(errMes[1]), contains_string("bad insert sql, sharding column/joinKey:ID not provided"))
    context.dble_conn.dropTable(key_value['table'], context)
