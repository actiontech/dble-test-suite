# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
import sys
import logging
import json

from lib.DBUtil import DBUtil

sys.path.append("..")
from behave import *
from hamcrest import *
from step_reload import get_admin_conn, get_dble_conn
from lib.generate_util import *

LOGGER = logging.getLogger('steps.function')

@then('Test the data types supported by the sharding column in "{sql_name}"')
def test_data_type(context, sql_name):
    LOGGER.info("test all data types")
    sql_path = "function/{0}".format(sql_name)
    context.execute_steps(u'Then execute sql in "{0}" to check read-write-split work fine and log dest slave'.format(sql_path))

def create_node_conn(context):
    context.manager_conn = get_admin_conn(context)
    sql = "show @@datanode"
    result, error = context.manager_conn.query(sql)
    context.manager_conn.close()

    datanode = {}
    if type(result) == tuple:
        for i in range(len(result)):

            datanode[result[i][0]] = result[i][1]
    port = 3306
    node_conn = {}
    for node in datanode.keys():
        user = context.cfg_mysql['user']
        password = context.cfg_mysql['password']
        host = datanode[node].split('/')[0]
        db = datanode[node].split('/')[1]
        LOGGER.info("{0} create, host:{1}, db:{2}".format(node, host, db))
        conn = DBUtil(host, user, password, db, port, context)
        node_conn[node] = conn
    return node_conn

@Then('Test the use of limit by the sharding column')
def test_use_limit(context):
    map = eval(context.text)
    tb = map["table"]
    t_key = map["key"]
    
    conn = get_dble_conn(context)

    drop_sql = "drop table if exists {0}".format(tb)
    conn.query(drop_sql)

    gen = generate()
    name = gen.rand_string(10)

    sql = "create table {0}({1} int, data varchar(10))".format(tb, t_key)
    conn.query(sql)

    sql = "alter table {0} drop column {1}".format(tb, t_key)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("The columns may be sharding keys or ER keys, are not allowed to alter sql"))

    sql = "update {0} set {1} = 1".format(tb, t_key)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("Sharding column can't be updated"))

    sql = "insert into {0} (data) values ('{1}')".format(tb, name)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("bad insert sql, sharding column/joinKey:ID not provided"))

    sql = "insert into {0} values (1+1, '{1}')".format(tb, name)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("Not Supported of Sharding Value EXPR"))

    conn.query(drop_sql)

    sql = "create table {0}(data varchar(10))".format(tb)
    conn.query(sql)

    sql = "insert into {0} values ('{1}')".format(tb, name)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("bad insert sql, sharding column/joinKey:ID not provided"))

    conn.query(drop_sql)
